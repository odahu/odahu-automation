variable "namespace" {
  type        = string
  description = "PostgreSQL operator namespace"
  default     = "postgresql"
}

variable "configuration" {
  type = object({
    cluster_name : string,
    enabled : bool,
    storage_size : string,
    replica_count : number,
  })
  description = "PostgreSQL configuration"
  default = {
    cluster_name  = "odahu-db"
    enabled       = false
    storage_size  = "8Gi"
    replica_count = "2"
  }
}

variable "databases" {
  type        = list(string)
  description = "List of PostgreSQL databases to be created on cluster init"
  default     = []
}

variable "helm_timeout" {
  type    = string
  default = "600"
}
