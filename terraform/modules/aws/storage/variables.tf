##################
# Required
##################

variable "cluster_name" {
  type        = string
  description = "ODAHU flow cluster name"
}

variable "kms_key_arn" {
  type        = string
  description = "The ARN of the AWS Key Management Service (AWS KMS) customer master key (CMK) to use when creating the encrypted volume"
}

##################
# Optional
##################

variable "tags" {
  type        = map
  default     = {}
  description = "HelmDefault SSH user"
}

variable "fs_type" {
  type        = string
  default     = "ext4"
  description = "HelmDefault SSH user"
}

variable "storage_type" {
  type        = string
  default     = "gp2"
  description = "HelmDefault SSH user"
}

variable "storage_class_name" {
  type        = string
  default     = "gp2-encrypted"
  description = "HelmDefault SSH user"
}
