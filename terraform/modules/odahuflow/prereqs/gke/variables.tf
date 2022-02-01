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

variable "argo_artifact_bucket" {
  type        = string
  default     = ""
  description = "Argo artifacts bucket"
}

variable "mlflow_artifact_bucket" {
  type        = string
  default     = ""
  description = "MLFlow artifacts bucket"
}

variable "log_expiration_days" {
  type        = number
  default     = 1
  description = "ODAHU flow logs expiration days"
}

# Bucket versioning
variable "data_enable_versioning" {
  type        = bool
  default     = true
  description = "Enable versioning for data bucket"
}

variable "log_enable_versioning" {
  type        = bool
  default     = true
  description = "Enable versioning for log bucket"
}

variable "mlflow_enable_versioning" {
  type        = bool
  default     = true
  description = "Enable versioning for mlflow bucket"
}

variable "argo_artifacts_enable_versioning" {
  type        = bool
  default     = true
  description = "Enable versioning for argo artifacts bucket"
}
########################

variable "kms_key_id" {
  type        = string
  description = "The id of a Cloud KMS key that will be used to encrypt objects inserted into this bucket"
}

variable "collector_sa_list" {
  type        = list
  description = "List of service accounts that should be allowed to use `collector` IAM role"
}

variable "vital_enable" {
  type        = bool
  default     = true
  description = "Enable vital parameter in odahuflow connections"
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

