variable "aws_region" {
  type        = string
  default     = ""
  description = "Region of AWS resources"
}

variable "cluster_name" {
  type        = string
  default     = ""
  description = "ODAHU flow cluster name"
}

variable "iam_role_arn" {
  type        = string
  description = "ARN of IAM role to attach to cluster autoscaler pod"
}

variable "cpu_max_limit" {
  type        = number
  default     = 30
  description = "Maximum CPU limit for autoscaling if it is enabled."
}

variable "mem_max_limit" {
  type        = number
  default     = 64
  description = "Maximum memory limit for autoscaling if it is enabled."
}

variable "helm_repo" {
  type        = string
  default     = "https://kubernetes.github.io/autoscaler"
  description = "URL of used Helm chart repository"
}

variable "helm_timeout" {
  type        = number
  default     = 600
  description = "Helm chart deploy timeout in seconds"
}

variable "helm_chart_version" {
  type        = string
  default     = "9.3.0"
  description = "Autoscaler Helm chart version"
}

variable "autoscaler_version" {
  type        = string
  default     = "1.16.5"
  description = "Autoscaler version"
}
