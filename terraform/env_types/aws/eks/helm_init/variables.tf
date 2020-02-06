variable "config_context_auth_info" {
  description = "Odahuflow cluster context auth"
}
variable "config_context_cluster" {
  description = "Odahuflow cluster context name"
}
variable "istio_helm_repo" {
  default = "https://storage.googleapis.com/istio-release/releases/1.4.3/charts"
}
variable "helm_repo" {}
