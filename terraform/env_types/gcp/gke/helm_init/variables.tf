variable "config_context_auth_info" {
  type        = string
  description = "Kubernetes cluster context auth"
}

variable "config_context_cluster" {
  type        = string
  description = "Kubernetes cluster context name"
}

variable "helm_repo" {
  type        = string
  description = "Odahuflow helm repo"
}
