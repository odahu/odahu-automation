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

# Integration between keycloak and oauth2_proxy
variable "oauth_client_id" {
  description = "OAuth 2 Client ID"
}
variable "oauth_client_secret" {
  description = "OAuth 2 Client Secret"
}
variable "oauth_redirect_url" {
  description = "OAuth 2 Redirect URL"
}
variable "oauth_oidc_issuer_url" {
  description = "OAuth 2 JWT token issuer"
}
variable "oauth_oidc_audience" {
  description = "OAuth 2 JWT token audience (for proxying valid & signatured JWT tokens)"
}
variable "oauth_oidc_scope" {
  description = "OAuth 2 Scope"
}

# OAuth2_proxy configuration
variable "oauth_helm_chart_version" {
  default     = "0.14.0"
  description = "version of oauth2 proxy helm chart"
}
variable "oauth_image_repository" {
  default     = "quay.io/pusher/oauth2_proxy"
  description = "image repository of oauth2 proxy"
}
variable "oauth_image_tag" {
  default     = "v4.0.0"
  description = "image tag of oauth2 proxy"
}
# OAuth2_proxy cookie configuration
variable "oauth_cookie_expire" {
  default     = "3600"
  description = "TTL for issuing cookies by oauth2_proxy"
}
variable "oauth_cookie_secret" {
  description = "Secret for issuing cookies by oauth2_proxy"
}