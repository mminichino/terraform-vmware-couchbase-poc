terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.27"
    }
  }

  required_version = ">= 0.14.9"
}

provider "aws" {
  region  = var.region_name
}

data "aws_ami" "couchbase_ami" {
  most_recent = true
  owners      = ["aws-marketplace"]

  filter {
    name = "name"

    values = [
      "CentOS Linux 7 x86_64 HVM EBS *",
    ]
  }
  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "root-device-type"
    values = ["ebs"]
  }
}

resource "aws_instance" "couchbase_nodes" {
  count                  = var.num_instances
  ami                    = data.aws_ami.couchbase_ami.id
  instance_type          = var.instance_type
  key_name               = var.ssh_key
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = element(var.subnet_ids, count.index)

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    iops        = var.root_volume_iops
  }

  tags = {
    Name = "${var.host_name_prefix}${format("%02d", count.index + var.start_num)}"
    Role = "${var.host_name_prefix}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/host_prep.sh"
    destination = "/home/${var.ssh_user}/host_prep.sh"
    connection {
      host        = self.private_ip
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.ssh_user}/host_prep.sh",
      "/home/${var.ssh_user}/host_prep.sh '${var.sw_version}'",
    ]
    connection {
      host        = self.private_ip
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
    }
  }
}

resource "aws_instance" "generator_nodes" {
  count                  = var.gen_instances
  ami                    = data.aws_ami.couchbase_ami.id
  instance_type          = var.gen_instance_type
  key_name               = var.ssh_key
  vpc_security_group_ids = var.security_group_ids
  subnet_id              = element(var.subnet_ids, count.index)

  root_block_device {
    volume_size = var.root_volume_size
    volume_type = var.root_volume_type
    iops        = var.root_volume_iops
  }

  tags = {
    Name = "${var.gen_name_prefix}${format("%02d", count.index + var.gen_start_num)}"
    Role = "${var.gen_name_prefix}"
  }

  provisioner "file" {
    source      = "${path.module}/scripts/gen_host_prep.sh"
    destination = "/home/${var.ssh_user}/gen_host_prep.sh"
    connection {
      host        = self.private_ip
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.ssh_user}/gen_host_prep.sh",
      "/home/${var.ssh_user}/gen_host_prep.sh",
    ]
    connection {
      host        = self.private_ip
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
    }
  }
}
