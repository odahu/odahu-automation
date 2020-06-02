variable "namespace" {
  type        = string
  description = "PostgreSQL operator namespace"
  default     = "postgresql"
}

variable "configuration" {
  type = object({
    enabled : bool,
    storage_size : string,
    replica_count : number,
    password : string
  })
  description = "PostgreSQL configuration"
  default = {
    enabled       = false
    storage_size  = "8Gi"
    replica_count = "2"
    password      = "notasecret"
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
