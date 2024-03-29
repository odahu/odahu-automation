variable "cluster_name" {
  type        = string
  default     = "odahu-flow"
  description = "ODAHU flow cluster name"
}

variable "region" {
  type        = string
  default     = "eu-central-1"
  description = "Region of resources"
}

variable "data_bucket" {
  type        = string
  description = "ODAHU flow data storage bucket"
}

variable "log_bucket" {
  type        = string
  default     = ""
  description = "ODAHU flow logs storage bucket"
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
variable "kms_key_arn" {
  type        = string
  description = "The ARN of the AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume"
}

variable "collector_sa_list" {
  type        = list
  description = "List of service accounts that should be allowed to use `collector` IAM role"
}

variable "jupyter_notebook_sa_list" {
  type        = list
  description = "List of service accounts that should be allowed to use `collector` IAM role"
}

variable "vital_enable" {
  type        = bool
  default     = true
  description = "Enable vital parameter in odahuflow connections"
}

variable "openid_connect_provider" {
  type = object({
    url = string
    arn = string
  })
  default = ({
    url = ""
    arn = ""
  })
  description = "OpenID connect provider for IRSA"
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
