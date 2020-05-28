# Common
variable "configuration" {
  type = object({
    enabled : bool,
    storage_size : string
  })
  description = "NFS configuration"
}

variable "helm_timeout" {
  default = "300"
  type    = string
}

variable "nfs_image_repo" {
  default     = "quay.io/kubernetes_incubator/nfs-provisioner"
  description = "Repository of nfs-provisioner image"
  type        = string
}

variable "nfs_image_tag" {
  default     = "v2.3.0"
  description = "Tag of nfs-provisioner image"
  type        = string
}
