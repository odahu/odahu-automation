variable "namespace" {
  type        = string
  default     = "postgresql"
  description = "PostgreSQL operator namespace"
}

variable "configuration" {
  type = object({
    cluster_name  = string
    enabled       = bool
    storage_size  = string
    replica_count = number
  })
  default = {
    cluster_name  = "odahu-db"
    enabled       = false
    storage_size  = "8Gi"
    replica_count = 2
  }
  description = "PostgreSQL configuration"
}

variable "databases" {
  type        = list(string)
  default     = []
  description = "List of PostgreSQL databases to be created on cluster init"
}

variable "helm_repo" {
  type        = string
  default     = "https://raw.githubusercontent.com/zalando/postgres-operator/master/charts/postgres-operator"
  description = "URL of used Helm chart repository"
}

variable "helm_timeout" {
  type        = number
  default     = 600
  description = "Helm chart deploy timeout in seconds"
}

variable "monitoring_namespace" {
  type        = string
  default     = "kube-monitoring"
  description = "Kubernetes namespace where Prometheus-operator is deployed"
}

