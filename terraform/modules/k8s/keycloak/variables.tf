##################
# Common
##################
variable "cluster_name" {
  default     = "legion"
  description = "Legion cluster name"
}
variable "root_domain" {
  description = "Legion cluster root domain"
}

##################
# Auth setup
##################

# Keycloak configuration
variable "codecentric_helm_repo" {
  default = "https://codecentric.github.io/helm-charts"
  description = "Codecentric helm repo for Kyecloak"
}
variable "keycloak_helm_chart_version" {
  default = "0.12.2"
  description = "version of keycloak helm chart"
}
variable "keycloak_image_repository" {
  default = "jboss/keycloak"
  description = "image repository of keycloak"
}
variable "keycloak_image_tag" {
  default = "6.0.1"
  description = "image tag of keycloak"
}
# Keycloak persistance configuration
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
# Integration with backend (identity provider) for keycloak
variable "github_org_name" {
  description = "Github Organization for keycloak authentication"
}
variable "github_client_id" {
  description = "Github Organization client ID"
}
variable "github_client_secret" {
  description = "Github Organization client Secret"
}

# Integration between keycloak and oauth2_proxy
variable "oauth_client_id" {
  description = "Client ID (is used by oauth2_proxy - keycloak integration)"
}
variable "oauth_client_secret" {
  description = "Client Secret (is used by oauth2_proxy - keycloak integration)"
}

# Static (tests) user configuration
variable "auth_static_user_email" {
  description = "Static user (for tests)"
}
variable "auth_static_user_pass" {
  description = "Static user's password (for tests)"
}
variable "auth_static_user_hash" {
  description = "Dex static user hash"
}
variable "auth_static_user_name" {
  description = "Dex static user username"
}
variable "auth_static_user_id" {
  description = "Dex static user user id"
}
