variable "namespaces" {
  default     = []
  description = "Kubernetes namespaces to populate docker credentials"
}

variable "sa_list" {
  default     = ["default"]
  description = "List of service accounts to use provided docker credentials as default"
}

variable "docker_secret_name" {
  default = "repo-json-key"
}

variable "docker_repo" {
  description = "Docker registry URL"
}

variable "docker_username" {
  description = "Docker registry username"
}

variable "docker_password" {
  description = "Docker registry password"
}
