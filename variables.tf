##########################################################
#
# Default values for creating a Couchbase cluster on AWS.
#
##########################################################

variable "host_name_prefix" {
  description = "Prefix for node names"
  default     = "perfdb"
  type        = string
}

variable "domain_name" {
  description = "Environment domain name"
  default     = ""
  type        = string
}

variable "dns_server" {
  description = "Environment DNS server"
  default     = ""
  type        = string
}

variable "sw_version" {
  description = "Software version (for yum install)"
  default     = "7.0.1-6102"
  type        = string
}

variable "region_name" {
  description = "Region name"
  default     = "us-east-2"
  type        = string
}

variable "instance_type" {
  description = "Instance type"
  default     = "c4.xlarge"
  type        = string
}

variable "gen_instance_type" {
  description = "Generator node instance type"
  default     = "c4.xlarge"
  type        = string
}

variable "index_memory" {
  description = "Index storage setting"
  default     = "false"
  type        = string
}

variable "num_instances" {
  description = "Number of instances in the cluster"
  default     = "3"
  type        = string
}

variable "gen_instances" {
  description = "Number of load generator nodes"
  default     = "1"
  type        = string
}

variable "start_num" {
  description = "Starting host number for instances in the cluster"
  default     = "1"
  type        = string
}

variable "gen_start_num" {
  description = "Starting host number for generator nodes"
  default     = "1"
  type        = string
}

variable "ssh_user" {
  description = "The default username for the AMI"
  type        = string
  default     = "centos"
}

variable "ssh_key" {
  description = "Key name to use"
  default     = ""
  type        = string
}

variable "ssh_private_key" {
  description = "The private key to use when connecting to the instances"
  default     = ""
  type        = string
}

variable "subnet_id" {
  description = "Subnet to launch the instances in"
  default     = ""
  type        = string
}

variable "vpc_id" {
  description = "VPC Id"
  default     = ""
  type        = string
}

variable "security_group_ids" {
  description = "Security group to assign to the instances"
  default     = [""]
  type        = list(string)
}

variable "root_volume_iops" {
  description = "IOPS (only for io1 volume type)"
  default     = "0"
  type        = string
}

variable "root_volume_size" {
  description = "The root volume size"
  default     = "50"
  type        = string
}

variable "root_volume_type" {
  description = "The root volume type"
  default     = "gp2"
  type        = string
}
