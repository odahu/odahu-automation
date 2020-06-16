variable "cluster_type" {
  type        = string
  default     = "odahuflow"
  description = "ODAHU flow cluster type"
}

variable "image_repo" {
  type        = string
  default     = "jtblin/kube2iam"
  description = "Docker image repository"
}

variable "image_tag" {
  type        = string
  default     = "0.10.9"
  description = "Docker image tag"
}

variable "chart_version" {
  type        = string
  default     = "2.5.0"
  description = "Helm chart version"
}

variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "Kubernetes namespace to deploy kube2iam"
}

variable "helm_timeout" {
  type        = number
  default     = 600
  description = "Helm chart deploy timeout in seconds"
}
