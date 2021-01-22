variable "cluster_name" {
  default     = "odahuflow"
  description = "ODAHU flow cluster name"
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume"
}

