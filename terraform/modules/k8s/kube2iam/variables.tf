variable "cluster_type" {
  default     = "legion"
  description = "Legion cluster type"
}

variable "image_repo" {
  default     = "jtblin/kube2iam"
  description = "docker repository"
}

variable "image_tag" {
  default     = "0.10.8"
  description = "docker image repository"
}

variable "chart_version" {
  default = "2.0.2"
}
