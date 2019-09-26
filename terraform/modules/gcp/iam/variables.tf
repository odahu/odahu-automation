variable "project_id" {
  description = "Target project id"
}

variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}

variable "service_account_iam_roles" {
  default = [
    "roles/logging.logWriter",
    "roles/monitoring.metricWriter",
    "roles/monitoring.viewer",
    "roles/storage.objectViewer",
    "roles/iam.serviceAccountTokenCreator",
  ]
  description = "Nodes SA roles"
}

