variable "elk_enabled" {
  default     = true
  description = "Flag to install ELK stack (true) or not (false)"
  type        = bool
}

variable "elk_namespace" {
  default     = "odahu-flow-elk"
  description = "ELK stack namespace name"
  type        = string
}

variable "odahu_helm_repo" {
  description = "ODAHU-flow helm repo"
  type        = string
}

variable "elasticsearch_helm_repo" {
  default     = "https://helm.elastic.co"
  description = "Elasticsearch helm repository"
  type        = string
}

variable "elasticsearch_chart_version" {
  default     = "7.6.2"
  description = "Elasticsearch helm chart version"
  type        = string
}

variable "elasticsearch_memory" {
  default     = "4"
  description = "Memory limit for Elasticsearch process (in GiB)"
  type        = string
}

variable "logstash_chart_version" {
  default     = "7.6.2"
  description = "Logstash helm chart version"
  type        = string
}

variable "elasticsearch_replicas" {
  default     = "1"
  description = "Replica count for the Elasticsearch StatefulSet"
  type        = string
}

variable "kibana_chart_version" {
  default     = "7.6.2"
  description = "Kibana helm chart version"
  type        = string
}

variable "logstash_replicas" {
  default     = "1"
  description = "Replica count for the Logstash StatefulSet"
  type        = string
}

variable "storage_class" {
  description = "Elasticsearch PVC k8s storage class"
  type        = string
}

variable "storage_size" {
  default     = "30Gi"
  description = "Elasticsearch nodes attached PVC size"
  type        = string
}

variable "cluster_domain" {
  description = "ODAHU Flow cluster FQDN"
  type        = string
}

variable "tls_secret_crt" {
  default     = ""
  description = "Ingress TLS certificate"
  type        = string
}

variable "tls_secret_key" {
  default     = ""
  description = "Ingress TLS key"
  type        = string
}

# Docker
variable "docker_repo" {
  description = "ODAHU flow Docker repo url"
  type        = string
}

variable "docker_username" {
  default     = ""
  description = "ODAHU flow Docker repo username"
  type        = string
}

variable "docker_password" {
  default     = ""
  description = "ODAHU flow Docker repo password"
  type        = string
}

variable "odahu_infra_version" {
  description = "ODAHU flow infra release version"
  type        = string
}

variable "logstash_input_config" {
  description = "Raw logstash input config"
}

variable "sa_key" {
  default = ""
  type    = string
}

variable "logstash_annotations" {
  default = {}
}

variable "cloud_type" {
  default = ""
  type    = string
}

variable "helm_timeout" {
  default = "600"
  type    = string
}
