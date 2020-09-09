variable "gcp_project_id" {
  type        = string
  description = "GCP project ID"
}

variable "gcp_region" {
  type        = string
  description = "Region of GCP resources"
}

variable "cluster_name" {
  type        = string
  description = "ODAHU flow cluster name"
}

variable "backup_settings" {
  type = object({
    enabled     = bool
    bucket_name = string
    schedule    = string
    retention   = string
  })
  default = {
    enabled     = false
    bucket_name = ""
    schedule    = ""
    retention   = ""
  }
  description = "Configuration for PostgreSQL backups"
}
