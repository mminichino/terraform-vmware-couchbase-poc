##

provider "vsphere" {
  user           = var.vsphere_user
  password       = var.vsphere_password
  vsphere_server = var.vsphere_server
  allow_unverified_ssl = true
}

data "vsphere_datacenter" "dc" {
  name = var.vsphere_datacenter
}
 
data "vsphere_resource_pool" "pool" {
  name          = "${var.vsphere_cluster}/Resources"
  datacenter_id = data.vsphere_datacenter.dc.id
}
 
data "vsphere_datastore" "datastore" {
  name          = var.vsphere_datastore
  datacenter_id = data.vsphere_datacenter.dc.id
}

data "vsphere_distributed_virtual_switch" "dvs" {
  name          = var.vsphere_dvs_switch
  datacenter_id = data.vsphere_datacenter.dc.id
}
 
data "vsphere_network" "network" {
  name          = var.vsphere_network
  datacenter_id = data.vsphere_datacenter.dc.id
  distributed_virtual_switch_uuid = data.vsphere_distributed_virtual_switch.dvs.id
}
 
data "vsphere_virtual_machine" "template" {
  name          = var.vsphere_template
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "random_id" "labid" {
  byte_length = 4
}

resource "vsphere_tag_category" "role" {
  name        = "terraform-role-category"
  cardinality = "SINGLE"
  description = "Managed by Terraform"

  associable_types = [
    "VirtualMachine",
  ]
}

resource "vsphere_tag_category" "services" {
  name        = "terraform-services-category"
  cardinality = "SINGLE"
  description = "Managed by Terraform"

  associable_types = [
    "VirtualMachine",
  ]
}

resource "vsphere_tag" "role" {
  for_each    = var.cluster_spec
  name        = "${each.key}-${random_id.labid.hex}"
  category_id = "${vsphere_tag_category.role.id}"
  description = "${each.value.node_role}"
}

resource "vsphere_tag" "services" {
  for_each    = var.cluster_spec
  name        = "${each.key}-${random_id.labid.hex}"
  category_id = "${vsphere_tag_category.services.id}"
  description = "${each.value.node_services}"
}

resource "vsphere_folder" "folder" {
  path          = "lab-${random_id.labid.hex}"
  type          = "vm"
  datacenter_id = data.vsphere_datacenter.dc.id
}

resource "vsphere_virtual_machine" "couchbase_nodes" {
  for_each         = var.cluster_spec
  name             = "${each.key}-${random_id.labid.hex}"
  num_cpus         = var.vm_num_vcpu
  memory           = var.vm_ram
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  folder           = vsphere_folder.folder.path

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "${each.key}-${random_id.labid.hex}"
        domain    = "${each.key}-${random_id.labid.hex}.${var.domain_name}"
      }
      network_interface {}
    }
  }

  tags = ["${vsphere_tag.role[each.key].id}","${vsphere_tag.services[each.key].id}"]

  provisioner "file" {
    source      = "${path.module}/scripts/callhostprep.sh"
    destination = "/home/${var.ssh_user}/callhostprep.sh"
    connection {
      host        = self.default_ip_address
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.ssh_user}/callhostprep.sh",
      "/home/${var.ssh_user}/callhostprep.sh -t cbnode -h ${each.key}-${random_id.labid.hex} -d ${var.domain_name} -n ${var.dns_server} -v ${var.sw_version}",
    ]
    connection {
      host        = self.default_ip_address
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
    }
  }
}

resource "vsphere_virtual_machine" "generator_nodes" {
  for_each         = var.generator_spec
  name             = "${each.key}-${random_id.labid.hex}"
  num_cpus         = var.vm_num_vcpu
  memory           = var.vm_ram
  datastore_id     = data.vsphere_datastore.datastore.id
  resource_pool_id = data.vsphere_resource_pool.pool.id
  guest_id         = data.vsphere_virtual_machine.template.guest_id
  scsi_type        = data.vsphere_virtual_machine.template.scsi_type
  folder           = vsphere_folder.folder.path

  network_interface {
    network_id = data.vsphere_network.network.id
  }

  disk {
    label = "disk0"
    size = data.vsphere_virtual_machine.template.disks.0.size
    thin_provisioned = data.vsphere_virtual_machine.template.disks.0.thin_provisioned
  }

  clone {
    template_uuid = data.vsphere_virtual_machine.template.id

    customize {
      linux_options {
        host_name = "${each.key}-${random_id.labid.hex}"
        domain    = "${each.key}-${random_id.labid.hex}.${var.domain_name}"
      }
      network_interface {}
    }
  }

  provisioner "file" {
    source      = "${path.module}/scripts/callhostprep.sh"
    destination = "/home/${var.ssh_user}/callhostprep.sh"
    connection {
      host        = self.default_ip_address
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
    }
  }

  provisioner "remote-exec" {
    inline = [
      "chmod +x /home/${var.ssh_user}/callhostprep.sh",
      "/home/${var.ssh_user}/callhostprep.sh -t generic -h ${each.key}-${random_id.labid.hex} -d ${var.domain_name} -n ${var.dns_server}",
    ]
    connection {
      host        = self.default_ip_address
      type        = "ssh"
      user        = var.ssh_user
      private_key = file(var.ssh_private_key)
    }
  }
}

resource "time_sleep" "wait_10_seconds" {
  create_duration = "10s"
  depends_on = [vsphere_virtual_machine.couchbase_nodes, vsphere_virtual_machine.generator_nodes]
}

resource "null_resource" "prep-hosts" {
  triggers = {
    cb_nodes = join(",", keys(vsphere_virtual_machine.couchbase_nodes))
    gen_nodes = join(",", keys(vsphere_virtual_machine.generator_nodes))
  }
  provisioner "local-exec" {
    command = "ansible-helper.py host-add-dns.yaml -S -h inventory_tf.py --dnsserver ${var.dns_server} --domain ${var.domain_name}"
    environment = {
       TERRAFORM_PATH = "${path.module}"
    }
  }
  depends_on = [time_sleep.wait_10_seconds]
}

resource "null_resource" "couchbase-init" {
  triggers = {
    cb_nodes = join(",", keys(vsphere_virtual_machine.couchbase_nodes))
    gen_nodes = join(",", keys(vsphere_virtual_machine.generator_nodes))
  }
  provisioner "local-exec" {
    command = "ansible-helper.py couchbase-init.yaml -S -h inventory_tf.py --cloud vmware"
    environment = {
       TERRAFORM_PATH = "${path.module}"
    }
  }
  depends_on = [null_resource.prep-hosts]
}
