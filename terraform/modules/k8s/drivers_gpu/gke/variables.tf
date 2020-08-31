variable "module_dependency" {
  type        = any
  default     = null
  description = "Terraform resource the module depends of (if any)"
}

variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "Kubernetes namespace where daemonset should be deployed"
}

variable "monitoring_namespace" {
  type        = string
  description = "Kubernetes namespace where Prometheus-operator is deployed"
}

variable "exporter_image" {
  type        = string
  default     = "nvidia/dcgm-exporter"
  description = "Nvidia GPU Prometheus exporter Docker image"
}

variable "exporter_tag" {
  type        = string
  default     = "1.7.2"
  description = "Nvidia GPU Prometheus exporter Docker image tag"
}

variable "exporter_port" {
  type        = number
  default     = 9400
  description = "Nvidia GPU Prometheus exporter metrics HTTP port"
}
