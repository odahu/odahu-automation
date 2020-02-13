variable "config_context_auth_info" {
  default     = ""
  description = "Kubernetes cluster context auth"
}

variable "config_context_cluster" {
  default     = ""
  description = "Kubernetes cluster context name"
}

variable "helm_repo" {
  description = "Odahuflow helm repo"
}
