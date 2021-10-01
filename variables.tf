##########################################################
#
# Default values for creating a Couchbase cluster on AWS.
#
##########################################################

variable "domain_name" {
  description = "Environment domain name"
  default     = "unix.us.com"
  type        = string
}

variable "dns_server" {
  description = "Environment DNS server"
  default     = "172.16.1.10"
  type        = string
}

variable "sw_version" {
  description = "Software version (for yum install)"
  default     = "7.0.1-6102"
  type        = string
}

variable "vsphere_user" {
  default     = "administrator@unix.us.com"
  type        = string
}

variable "vsphere_password" {
  default     = "Passw0rd!"
  type        = string
}

variable "vsphere_server" {
  default     = "172.16.1.19"
  type        = string
}

variable "vsphere_datacenter" {
  default     = "HomeLab"
  type        = string
}

variable "vsphere_cluster" {
  default     = "HomeLab"
  type        = string
}

variable "vsphere_datastore" {
  default     = "vsanDatastore"
  type        = string
}

variable "vsphere_dvs_switch" {
  default     = "DSwitch-10GbE"
  type        = string
}

variable "vsphere_network" {
  default     = "lab-vpc-02"
  type        = string
}

variable "vsphere_template" {
  default     = "CentOS-7-Template"
  type        = string
}

variable "vm_num_vcpu" {
  default     = "4"
  type        = string
}

variable "vm_ram" {
  default     = "8192"
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

variable "ssh_user" {
  description = "The default username for setup"
  type        = string
  default     = "admin"
}

variable "ssh_private_key" {
  description = "The private key to use when connecting to the instances"
  default     = "/home/admin/.ssh/homelab-default-key"
  type        = string
}

