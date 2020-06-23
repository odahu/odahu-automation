variable "namespaces" {
  type        = list(string)
  default     = []
  description = "Kubernetes namespaces to populate docker credentials"
}

variable "sa_list" {
  type        = list(string)
  default     = ["default"]
  description = "List of service accounts to use provided docker credentials as default"
}

variable "docker_secret_name" {
  type        = string
  default     = "repo-json-key"
  description = "Name of k8s secret in which Docker registry password is stored"
}

variable "docker_repo" {
  type        = string
  description = "Docker registry URL"
}

variable "docker_username" {
  type        = string
  description = "Docker registry username"
}

variable "docker_password" {
  type        = string
  description = "Docker registry password"
}
