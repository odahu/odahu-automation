variable "cluster_type" {
  default     = "odahuflow"
  description = "Odahuflow cluster type"
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
  default = "2.3.0"
}

variable "helm_timeout" {
  default = "600"
}
