# Common
variable "project_id" {
  type        = string
  description = "Google Cloud Project ID"
}

variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
}

variable "bucket" {
  type        = string
  description = "DAGs bucket name"
}

variable "workflows_namespace" {
  type        = string
  description = "Namespace to run Argo Workflows"
}

variable "namespace" {
  type        = string
  description = "Namespace to run Argo server"
}

variable "kms_key_id" {
  type        = string
  description = "The id of a Cloud KMS key that will be used to encrypt cluster disks"
}
