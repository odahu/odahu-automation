variable "config_context_auth_info" {
  description = "Legion cluster context auth"
}
variable "config_context_cluster" {
  description = "Legion cluster context name"
}
variable "project_id" {
  description = "Target project id"
}
variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}
variable "zone" {
  description = "Default zone"
}