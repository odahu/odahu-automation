################## 
# Common 
################## 
variable "cluster_domain" {
  type        = string
  description = "ODAHU flow cluster FQDN"
}

variable "tls_secret_crt" {
  type        = string
  default     = ""
  description = "Ingress TLS certificate"
}

variable "tls_secret_key" {
  type        = string
  default     = ""
  description = "Ingress TLS key"
}
##################
# Argo setup
##################

variable "argo_wf_helm_chart_version" {
  type        = string
  default     = "0.16.6"
  description = "version of Argo Forkflows helm chart"
}

variable "argo_events_helm_chart_version" {
  type        = string
  default     = "1.2.3"
  description = "version of Argo-events helm chart"
}

variable "helm_repo" {
  type        = string
  default     = "https://argoproj.github.io/argo-helm"
  description = "URL of used Helm chart repository"
}

variable "helm_timeout" {
  type        = number
  default     = 600
  description = "Helm chart deploy timeout in seconds"
}

variable "workflows_sa" {
  type        = string
  description = "Cloud service account name to use when running workflows. Should be attached to k8s sa via annotation"
}

variable "pgsql" {
  type = object({
    enabled          = bool
    db_host          = string
    db_name          = string
    db_user          = string
    db_password      = string
    secret_namespace = string
    secret_name      = string
  })
  default = {
    enabled          = false
    db_host          = ""
    db_name          = ""
    db_user          = ""
    db_password      = ""
    secret_namespace = ""
    secret_name      = ""
  }
  description = "PostgreSQL settings for Argo Workflows"
}

variable "configuration" {
  type = object({
    enabled             = bool
    namespace           = string
    workflows_namespace = string
    artifact_bucket     = string
    node_pool           = any
  })
  default = {
    enabled             = false
    namespace           = "argo"
    workflows_namespace = "argo"
    artifact_bucket     = ""
    node_pool = {
      argo-workflows = {
        init_node_count = 0
        min_node_count  = 0
        max_node_count  = 1
        preemptible     = true
        machine_type    = "n1-standard-2"
        disk_size_gb    = 40
        labels = {
          machine_type = "n1-standard-2"
          mode         = "argo-workflows"
        }
        taints = [
          {
            key    = "dedicated"
            effect = "NO_SCHEDULE"
            value  = "argo"
          }
        ]
      }
    }
  }
  description = "Argo configuration"
}
