variable "pg_endpoint" {
  type        = string
  description = "PostgreSQL service endpoint"
}

variable "pg_databases" {
  type        = list(string)
  default     = []
  description = "List of PostgreSQL databases to be backed up"
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
  description = "Common configuration for PostgreSQL backups"
}

variable "backup_job_config" {
  type = object({
    rclone      = string
    bucket      = string
    annotations = map(string)
  })
  description = "Cloud-specific PostgreSQL backup job settings: rclone config file content, pod annotations"
}

variable "docker_repo" {
  type        = string
  description = "ODAHU flow Docker repo URL"
}

variable "docker_image" {
  type        = string
  default     = "odahu-flow-pg-backup"
  description = "Docker image to create backup cronjob from"
}

variable "docker_tag" {
  type        = string
  default     = "latest"
  description = "Registry tag of docker image to create backup cronjob"
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

variable "docker_secret_name" {
  type        = string
  default     = "repo-json-key"
  description = "ODAHU flow Docker repo secret name to create"
}
