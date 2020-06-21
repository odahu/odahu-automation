variable "namespace" {
  type        = string
  default     = "postgresql"
  description = "PostgreSQL operator namespace"
}

variable "configuration" {
  type = object({
    cluster_name  = string
    enabled       = bool
    storage_size  = string
    replica_count = number
  })
  default = {
    cluster_name  = "odahu-db"
    enabled       = false
    storage_size  = "8Gi"
    replica_count = 2
  }
  description = "PostgreSQL configuration"
}

variable "databases" {
  type        = list(string)
  default     = []
  description = "List of PostgreSQL databases to be created on cluster init"
}

variable "helm_timeout" {
  type        = number
  default     = 600
  description = "Helm chart deploy timeout in seconds"
}
