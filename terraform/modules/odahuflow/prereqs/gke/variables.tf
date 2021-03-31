variable "project_id" {
  type        = string
  default     = ""
  description = "Target project id"
}

variable "cluster_name" {
  type        = string
  default     = "odahu-flow"
  description = "ODAHU flow cluster name"
}

variable "region" {
  type        = string
  default     = "us-east1"
  description = "Region of resources"
}

variable "data_bucket" {
  type        = string
  description = "ODAHU flow data storage bucket name"
}

variable "log_bucket" {
  type        = string
  default     = ""
  description = "ODAHU flow logs storage bucket"
}

variable "log_expiration_days" {
  type        = number
  default     = 1
  description = "ODAHU flow logs expiration days"
}

variable "kms_key_id" {
  type        = string
  description = "The id of a Cloud KMS key that will be used to encrypt objects inserted into this bucket"
}

variable "collector_sa_list" {
  type        = list
  description = "List of service accounts that should be allowed to use `collector` IAM role"
}

variable "uniform_bucket_level_access" {
  type        = string
  default     = "true"
  description = "Enable or not uniform_bucket_level_access option"
}

variable "fluentd_resources" {
  type = object({
    cpu_requests    = string
    memory_requests = string
    cpu_limits      = string
    memory_limits   = string
  })
  default = {
    cpu_requests    = "300m"
    memory_requests = "1Gi"
    cpu_limits      = "2"
    memory_limits   = "3Gi"
  }
  description = "Fluentd container resources"
}

