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

variable "syncer_sa_list" {
  type        = list
  description = "List of syncer service accounts that should be allowed to use `syncer` IAM role"
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

