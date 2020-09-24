variable "namespace" {
  type        = string
  default     = "kube-system"
  description = "Kubernetes namespace used for deployed Helm chart"
}

variable "helm_timeout" {
  type        = number
  default     = 600
  description = "Helm chart deploy timeout in seconds"
}

variable "storage_class_name" {
  type        = string
  default     = "odahu-csi"
  description = "Kubernetes CSI storage class name"
}
