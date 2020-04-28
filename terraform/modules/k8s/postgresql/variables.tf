variable "namespace" {
  description = "Postgres namespace"
  default     = "postgres"
}

variable "allowed_networks" {
  default     = "0.0.0.0/0"
  description = "Postgres pg_hba allowed networks"
}

variable "configuration" {
  type = object({
    enabled : bool,
    storage_size : string,
    replica_count : number,
    password : string
  })
  description = "Postgres configuration"
}

variable "monitoring_dependency" {}

# Docker
variable "docker_repo" {
  description = "Odahuflow Docker repo url"
}

variable "docker_username" {
  default     = ""
  description = "Odahuflow Docker repo username"
}

variable "docker_password" {
  default     = ""
  description = "Odahuflow Docker repo password"
}

variable "helm_timeout" {
  default = "600"
}
