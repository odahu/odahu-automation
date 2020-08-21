variable "namespace" {
  type        = string
  default     = "vault"
  description = "Vault namespace"
}

variable "vault_tls_secret_name" {
  type        = string
  default     = "vault-tls"
  description = "Kubernetes secret with custom Vault TLS data (generated in Helm)"
}

variable "configuration" {
  type = object({
    enabled = bool
  })
  description = "Vault configuration"
}

variable "helm_repo" {
  type        = string
  default     = "https://kubernetes-charts.banzaicloud.com"
  description = "URL of used Helm chart repository"
}

variable "helm_timeout" {
  type        = number
  default     = 600
  description = "Helm chart deploy timeout in seconds"
}

variable "pgsql" {
  type = object({
    enabled     = bool
    db_host     = string
    db_name     = string
    db_user     = string
    db_password = string
  })
  default = {
    enabled     = false
    db_host     = ""
    db_name     = ""
    db_user     = ""
    db_password = ""
  }
  description = "PostgreSQL settings for Vault storage backend"
}
