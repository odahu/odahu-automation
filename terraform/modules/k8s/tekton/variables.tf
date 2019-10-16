variable "legion_helm_repo" {
  description = "Legion helm repo"
}

variable "legion_infra_version" {
  description = "Legion infra release version"
}

variable "namespace" {
  description = "Tekton namespace"
  default = "tekton-pipelines"
}
