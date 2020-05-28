variable "namespace" {
  type        = string
  default     = "postgres"
  description = "PostgreSQL namespace name"
}

variable "allowed_networks" {
  type        = string
  default     = "0.0.0.0/0"
  description = "PostgreSQL allowed networks in `pg_hba` config"
}

variable "configuration" {
  type = object({
    enabled : bool,
    storage_size : string,
    replica_count : number,
    password : string
  })
  description = "PostgreSQL configuration"
}

variable "monitoring_dependency" {
  type        = any
  description = "Resource dependency from one of Terraform modules"
}

variable "helm_timeout" {
  type    = string
  default = "600"
}
