##########################################################
#
# Default values for creating a Couchbase cluster on AWS.
#
##########################################################

variable "cluster_spec" {
  description = "Map of cluster nodes and services."
  type        = map
  default     = {
    cbnode-01 = {
      node_number      = 1,
      node_services    = "data,index,query",
      node_role        = "database"
      vsphere_template = "CentOS-7-Template",
    }
    cbnode-02 = {
      node_number      = 2,
      node_services    = "data,index,query",
      node_role        = "database"
      vsphere_template = "CentOS-7-Template",
    }
    cbnode-03 = {
      node_number      = 3,
      node_services    = "data,index,query",
      node_role        = "database"
      vsphere_template = "CentOS-7-Template",
    }
  }
}

variable "generator_spec" {
  description = "Map of cluster nodes and services."
  type        = map
  default     = {
    loadgen-01 = {
      node_number      = 1,
      node_services    = "docker",
      node_role        = "generator"
      vsphere_template = "CentOS-7-Template",
    }
  }
}
