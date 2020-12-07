variable "elk_enabled" {
  type        = bool
  default     = true
  description = "Flag to install ELK stack (true) or not (false)"
}

variable "elk_namespace" {
  type        = string
  default     = "odahu-flow-elk"
  description = "ELK stack namespace name"
}

variable "odahu_helm_repo" {
  type        = string
  description = "ODAHU flow helm repo"
}

variable "es_helm_repo" {
  type        = string
  default     = "https://helm.elastic.co"
  description = "Elasticsearch helm repository"
}

variable "es_chart_version" {
  type        = string
  default     = "7.9.0"
  description = "Elasticsearch helm chart version"
}

variable "es_memory" {
  type        = string
  default     = "4"
  description = "Memory limit for Elasticsearch process (in GiB)"
}

variable "es_replicas" {
  type        = number
  default     = 1
  description = "Replica count for the Elasticsearch StatefulSet"
}

variable "es_index_settings" {
  type = map(object({
    size   = string
    age    = string
    shards = number
  }))
  default = {
    "logstash" = {
      size   = "1GB"
      age    = "4d"
      shards = 1
    },
    "odahu-flow" = {
      size   = "1GB"
      age    = "25d"
      shards = 1
    },
    "opa" = {
      size   = "1GB"
      age    = "4d"
      shards = 1
    }
  }
  description = "Settings to configure Elasticsearch index templates and index lifecycle policies"
}

variable "logstash_chart_version" {
  type        = string
  default     = "7.9.0"
  description = "Logstash helm chart version"
}

variable "kibana_chart_version" {
  type        = string
  default     = "7.9.0"
  description = "Kibana helm chart version"
}

variable "logstash_replicas" {
  type        = number
  default     = 1
  description = "Replica count for the Logstash StatefulSet"
}

variable "storage_size" {
  type        = string
  default     = "30Gi"
  description = "Elasticsearch nodes attached PVC size"
}

variable "cluster_domain" {
  type        = string
  description = "ODAHU Flow cluster FQDN"
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

# Docker
variable "docker_repo" {
  type        = string
  description = "ODAHU flow Docker repo url"
}

variable "docker_username" {
  type        = string
  default     = ""
  description = "ODAHU flow Docker repo username"
}

variable "docker_password" {
  type        = string
  default     = ""
  description = "ODAHU flow Docker repo password"
}

variable "odahu_infra_version" {
  type        = string
  description = "ODAHU flow infra release version"
}

variable "logstash_input_config" {
  type        = string
  description = "Raw logstash input config"
}

variable "sa_key" {
  type        = string
  default     = ""
  description = "Kubernetes serviceAccount key"
}

variable "logstash_annotations" {
  type        = map(any)
  default     = {}
  description = "Logstash annotations"
}

variable "cloud_type" {
  type        = string
  default     = ""
  description = "Cloud type attribute (aws, azure, gcp)"
}

variable "helm_timeout" {
  type        = number
  default     = 900
  description = "Helm chart deploy timeout in seconds"
}
