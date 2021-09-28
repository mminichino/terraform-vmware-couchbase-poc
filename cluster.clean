##########################################################
#
# Default values for creating a Couchbase cluster on AWS.
#
##########################################################

variable "cluster_spec" {
  description = "Map of cluster nodes and services."
  type        = map
  default     = {
    cbnode = {
      node_number     = 1,
      node_services   = "data,index,query",
      node_role       = "database"
      instance_type   = "c4.xlarge",
    },
    cbnode = {
      node_number     = 2,
      node_services   = "data,index,query",
      node_role       = "database"
      instance_type   = "c4.xlarge",
    }
    cbnode = {
      node_number     = 3,
      node_services   = "data,index,query",
      node_role       = "database"
      instance_type   = "c4.xlarge",
    }
  }
}

variable "generator_spec" {
  description = "Map of cluster nodes and services."
  type        = map
  default     = {
    loadgen = {
      node_number     = 1,
      node_services   = "docker",
      node_role       = "generator"
      instance_type   = "c4.xlarge",
    }
  }
}
