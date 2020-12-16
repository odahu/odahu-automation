# Common
variable "cluster_domain" {
  type        = string
  description = "ODAHU flow cluster FQDN"
}

variable "namespace" {
  type        = string
  default     = "airflow"
  description = "Airflow namespace"
}

variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
}

variable "tls_secret_crt" {
  type        = string
  default     = ""
  description = "Ingress TLS certificate"
}

variable "tls_secret_key" {
  type        = string
  default     = ""
  description = "Ingress TLS key"
}

variable "odahu_airflow_plugin_version" {
  type        = string
  description = "ODAHU Airflow plugin version to use"
}

# Docker
variable "docker_repo" {
  type        = string
  description = "ODAHU flow Docker repo url"
}

variable "docker_username" {
  type        = string
  default     = ""
  description = "ODAHU flow Docker repo username"
}

variable "docker_password" {
  type        = string
  default     = ""
  description = "ODAHU flow Docker repo password"
}

variable "wine_connection" {
  type        = map(string)
  description = "GCP wine connection service account private key"
}

variable "airflow_variables" {
  type        = map(string)
  description = "Variables to create in Airflow instance"
}

variable "oauth_oidc_token_endpoint" {
  type        = string
  description = "Auth endpoint"
}

variable "service_account" {
  type = object({
    client_id     = string
    client_secret = string
  })
  description = "Service account that Airflow should use to connect ODAHU"
}

variable "configuration" {
  type = object({
    enabled          = bool
    storage_size     = string
    log_storage_size = string
    fernet_key       = string
    dag_repo         = string
    dag_bucket       = string
    dag_bucket_path  = string
  })
  description = "Airflow configuration"
}

variable "examples_version" {
  type        = string
  description = "Version of test data to upload"
}

variable "helm_repo" {
  type        = string
  default     = "https://charts.helm.sh/stable"
  description = "URL of used Helm chart repository"
}

variable "helm_timeout" {
  type        = number
  default     = 500
  description = "Helm chart deploy timeout in seconds"
}

variable "pgsql" {
  type = object({
    enabled          = bool
    db_host          = string
    db_name          = string
    db_user          = string
    db_password      = string
    secret_namespace = string
    secret_name      = string
  })
  default = {
    enabled          = false
    db_host          = ""
    db_name          = ""
    db_user          = ""
    db_password      = ""
    secret_namespace = ""
    secret_name      = ""
  }
  description = "PostgreSQL settings for Airflow"
}
