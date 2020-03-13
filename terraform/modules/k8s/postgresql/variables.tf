variable "namespace" {
  description = "Postgres namespace"
  default     = "postgres"
}

variable "allowed_networks" {
  default     = "0.0.0.0/0"
  description = "Postgres pg_hba allowed networks"
}

variable "password" {
  default     = "postgres"
  description = "Postgres admin user password"
}

variable "configuration" {
  type = object({
    enabled : bool,
    storage_size : string,
    replica_count : number
  })
  description = "Postgres configuration"
}

variable "monitoring_dependency" {}
