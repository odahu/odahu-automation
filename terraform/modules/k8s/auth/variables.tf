################## 
# Common 
################## 
variable "domain_name" {
  type        = string
  default     = "odahu-flow.example.com"
  description = "ODAHU cluster endpoint FQDN"
}

##################
# Auth setup
##################

# Integration between keycloak and oauth2_proxy
variable "oauth_client_id" {
  type        = string
  description = "OAuth 2 Client ID"
}

variable "oauth_client_secret" {
  type        = string
  description = "OAuth 2 Client Secret"
}

variable "oauth_redirect_url" {
  type        = string
  default     = ""
  description = "OAuth 2 Redirect URL"
}

variable "oauth_oidc_issuer_url" {
  type        = string
  description = "OAuth 2 JWT token issuer"
}

variable "oauth_oidc_audience" {
  type        = string
  description = "OAuth 2 JWT token audience (for proxying valid & signatured JWT tokens)"
}

variable "oauth_oidc_scope" {
  type        = string
  description = "OAuth 2 Scope"
}

# OAuth2_proxy configuration
variable "oauth_helm_chart_version" {
  type        = string
  default     = "3.1.0"
  description = "version of oauth2 proxy helm chart"
}

variable "oauth_image_repository" {
  type        = string
  default     = "quay.io/oauth2-proxy/oauth2-proxy"
  description = "Image repository of oauth2-proxy"
}

variable "oauth_image_tag" {
  type        = string
  default     = "v5.1.1"
  description = "Image tag of oauth2-proxy"
}

# OAuth2_proxy cookie configuration
variable "oauth_cookie_expire" {
  type        = string
  default     = "1h0m0s"
  description = "TTL for issuing cookies by oauth2_proxy (format: 168h0m0s)"
}

variable "oauth_cookie_secret" {
  type        = string
  description = "Secret for issuing cookies by oauth2_proxy"
}

variable "helm_repo" {
  type        = string
  default     = "https://charts.helm.sh/stable"
  description = "URL of used Helm chart repository"
}

variable "helm_timeout" {
  type        = number
  default     = 600
  description = "Helm chart deploy timeout in seconds"
}
