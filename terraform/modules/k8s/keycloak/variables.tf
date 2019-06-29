##################
# Common
##################
variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}
variable "legion_helm_repo" {
  description = "Legion helm repo"
}
variable "root_domain" {
  description = "Legion cluster root domain"
}

##################
# Auth setup
##################
variable "codecentric_helm_repo" {
  default = "https://codecentric.github.io/helm-charts"
  description = "Codecentric helm repo for Kyecloak"
}
variable "gatekeeper_helm_repo" {
  default = "https://gabibbo97.github.io/charts/"
  description = "Keycloak gatekeeper helm repo"
}
variable "keycloak_admin_user" {
  description = "Keycloak admin user"
}
variable "keycloak_admin_pass" {
  description = "Keycloak admin pass"
}
variable "keycloak_db_user" {
  description = "Keycloak db admin user"
}
variable "keycloak_db_pass" {
  description = "Keycloak db admin pass"
}
variable "keycloak_pg_user" {
  description = "Keycloak postgres user"
}
variable "keycloak_pg_pass" {
  description = "Keycloak postgres pass"
}