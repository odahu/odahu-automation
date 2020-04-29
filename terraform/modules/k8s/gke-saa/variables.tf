##################
# Common
##################
variable "odahu_infra_version" {
  description = "Odahuflow infra release version"
}

variable "helm_repo" {
  description = "Odahuflow helm repo"
}

variable "cluster_type" {
  description = "Cluster type"
}

########################
# GKE Service Account Assigner
########################
variable "gke_saa_default_scopes" {
  default     = "https://www.googleapis.com/auth/logging.write,https://www.googleapis.com/auth/monitoring,https://www.googleapis.com/auth/servicecontrol,https://www.googleapis.com/auth/service.management.readonly,https://www.googleapis.com/auth/trace.append"
  description = "Default scopes to provide for pods"
}

variable "gke_saa_default_sa" {
  default     = "default"
  description = "Default service account to provide for pods"
}

variable "gke_saa_sa_name" {
  default     = "gke_saa_sa"
  description = "Name of k8s Service Account that Assigner pod should use to run"
}

variable "gke_saa_image_repo" {
  default     = "imduffy15/k8s-gke-service-account-assigner"
  description = "GKE Service Account Assigner docker repository"
}

variable "gke_saa_image_tag" {
  default     = "v0.0.2"
  description = "GKE Service Account Assigner docker image repository"
}

variable "gke_saa_host_port" {
  default     = "8181"
  description = "GKE Service Account Assigner host port"
}

variable "gke_saa_container_port" {
  default     = "8181"
  description = "GKE Service Account Assigner container port"
}

variable "gke_saa_name" {
  default     = "gke-sa-assigner"
  description = "GKE Service Account Assigner name"
}

variable "helm_timeout" {
  default = "300"
}
