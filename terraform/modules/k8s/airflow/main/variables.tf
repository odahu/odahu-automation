# Common
variable "cluster_domain" {
  description = "ODAHU flow cluster FQDN"
  type        = string
}

variable "namespace" {
  description = "Airflow namespace"
  default     = "airflow"
  type        = string
}

variable "cluster_name" {
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
  type        = string
}

variable "tls_secret_crt" {
  description = "Ingress TLS certificate"
  default     = ""
  type        = string
}

variable "tls_secret_key" {
  description = "Ingress TLS key"
  default     = ""
  type        = string
}

variable "odahu_airflow_plugin_version" {
  description = "ODAHU Airflow plugin version to use"
  type        = string
}

# Docker
variable "docker_repo" {
  description = "ODAHU flow Docker repo url"
  type        = string
}

variable "docker_username" {
  default     = ""
  description = "ODAHU flow Docker repo username"
  type        = string
}

variable "docker_password" {
  default     = ""
  description = "ODAHU flow Docker repo password"
  type        = string
}

variable "wine_connection" {
  description = "GCP wine connection service account private key"
  type        = map(string)
}

variable "airflow_variables" {
  description = "Variables to create in Airflow instance"
  type        = map(string)
}

variable "oauth_oidc_token_endpoint" {
  description = "Auth endpoint"
  type        = string
}

variable "service_account" {
  description = "Service account that Airflow should use to connect ODAHU"
  type = object({
    client_id : string
    client_secret : string
  })
}

variable "configuration" {
  type = object({
    enabled : bool,
    storage_size : string,
    log_storage_size : string,
    fernet_key : string,
    dag_repo : string,
    dag_bucket : string,
    dag_bucket_path : string
  })
  description = "Airflow configuration"
}

variable "examples_version" {
  description = "Version of test data to upload"
  type        = string
}

variable "helm_timeout" {
  default = "500"
  type    = string
}
