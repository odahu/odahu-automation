variable "helm_values" {
  type        = map(any)
  description = "Extra helm nignx values"
}

variable "namespace" {
  type    = string
  default = "kube-system"
}
