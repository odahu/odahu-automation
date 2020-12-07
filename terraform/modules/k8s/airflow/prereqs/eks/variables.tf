# Common
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

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume"
}

