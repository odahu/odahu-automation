##################
# Common
##################
variable "odahu_infra_version" {
  type        = string
  description = "ODAHU flow infra release version"
}

variable "helm_repo" {
  type        = string
  description = "ODAHU flow helm repo"
}

variable "helm_timeout" {
  type        = number
  default     = 300
  description = "Helm chart deploy timeout in seconds"
}

variable "cluster_type" {
  type        = string
  description = "Cluster type"
}

########################
# GKE Service Account Assigner
########################
variable "gke_saa_default_scopes" {
  type = list(string)
  default = [
    "https://www.googleapis.com/auth/logging.write",
    "https://www.googleapis.com/auth/monitoring",
    "https://www.googleapis.com/auth/servicecontrol",
    "https://www.googleapis.com/auth/service.management.readonly",
    "https://www.googleapis.com/auth/trace.append"
  ]
  description = "Default scopes to provide for pods"
}

variable "gke_saa_default_sa" {
  type        = string
  default     = "default"
  description = "Default service account to provide for pods"
}

variable "gke_saa_sa_name" {
  type        = string
  default     = "gke_saa_sa"
  description = "Name of k8s Service Account that Assigner pod should use to run"
}

variable "gke_saa_image_repo" {
  type        = string
  default     = "imduffy15/k8s-gke-service-account-assigner"
  description = "GKE Service Account Assigner docker repository"
}

variable "gke_saa_image_tag" {
  type        = string
  default     = "v0.0.2"
  description = "GKE Service Account Assigner docker image repository"
}

variable "gke_saa_host_port" {
  type        = number
  default     = 8181
  description = "GKE Service Account Assigner host port"
}

variable "gke_saa_container_port" {
  type        = number
  default     = 8181
  description = "GKE Service Account Assigner container port"
}

variable "gke_saa_name" {
  type        = string
  default     = "gke-sa-assigner"
  description = "GKE Service Account Assigner name"
}

variable "gke_saa_namespace" {
  type        = string
  default     = "kube-system"
  description = "GKE Service Account Assigner namespace"
}
