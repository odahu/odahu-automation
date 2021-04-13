# Common
variable "cluster_name" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
}

variable "bucket" {
  type        = string
  description = "Argo artifacts bucket name"
}

variable "region" {
  type        = string
  description = "DAGs bucket region"
}

variable "workflows_namespace" {
  type        = string
  description = "Namespace to run Argo Workflows"
}

variable "namespace" {
  type        = string
  description = "Namespace to run Argo server"
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume"
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
