# Common
variable "project_id" {
  description = "Google Cloud Project ID"
}

variable "domain" {
  description = "Odahuflow FQDN"
}

variable "namespace" {
  description = "Airflow namespace"
  default     = "airflow"
}

variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "nfs_dependency" {}

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

# Airflow configuration
variable "postgres_password" {
  description = "Postgres password"
}

variable "oauth_oidc_token_endpoint" {
  description = "Auth endpoint"
}

variable "service_account" {
  description = "Service account that Airflow should use to connect ODAHU"
}

variable "configuration" {
  type = object({
    enabled : bool,
    storage_size : string,
    log_storage_size : string,
    fernet_key : string
  })
  description = "Airflow configuration"
}

# Test data
variable "wine_bucket" {
  description = "Wine bucket name"
}

variable "wine_data_url" {
  description = "Wine example data URL"
}

variable "examples_version" {
  description = "Examples version"
}
