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

variable "wine_bucket" {
  type        = string
  description = "Wine bucket name"
}

variable "dag_bucket" {
  type        = string
  description = "DAGs bucket name"
}

variable "dag_bucket_path" {
  type        = string
  description = "DAGs bucket subpath"
}

variable "region" {
  type        = string
  description = "DAGs bucket region"
}

variable "kms_key_id" {
  type        = string
  description = "The id of a Cloud KMS key that will be used to encrypt cluster disks"
}

variable "syncer_sa_list" {
  type        = list
  description = "List of syncer service accounts that should be allowed to use `syncer` IAM role"
}

