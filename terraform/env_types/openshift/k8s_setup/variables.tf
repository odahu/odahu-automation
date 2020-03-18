##################
# Common
##################
variable "cluster_type" {
  description = "Cluster type"
}

variable "project_id" {
  description = "Target project id"
}

variable "zone" {
  description = "Default zone"
}

variable "region" {
  description = "Region of resources"
}

variable "cluster_name" {
  default     = "odahuflow"
  description = "Odahuflow cluster name"
}

variable "config_context_auth_info" {
  description = "Kubernetes cluster context auth"
}

variable "config_context_cluster" {
  description = "Kubernetes cluster context name"
}

variable "helm_repo" {
  description = "Odahuflow helm repo"
}

variable "odahu_infra_version" {
  description = "Odahuflow infra release version"
}

variable "cluster_domain_name" {
  description = "Odahuflow cluster FQDN"
}

variable "docker_repo" {
  description = "Odahuflow Docker repo url"
}

variable "docker_username" {
  default     = ""
  description = "Odahuflow Docker repo username"
}

variable "docker_password" {
  default     = ""
  description = "Odahuflow Docker repo password"
}

#variable "tls_key" {
#  description = "TLS key for Odahuflow cluster"
#}

#variable "tls_crt" {
#  description = "TLS certificate file for Odahuflow cluster"
#}

##################
# OAuth2
##################
variable "oauth_client_id" {
  description = "OAuth2 Client ID"
}

variable "oauth_client_secret" {
  description = "OAuth2 Client Secret"
}

variable "oauth_cookie_secret" {
  description = "OAuth2 Cookie Secret"
}

variable "oauth_oidc_issuer_url" {
  description = "OAuth2/OIDC provider Issuer URL"
}

variable "oauth_oidc_audience" {
  description = "Oauth2 access token audience"
}

variable "oauth_oidc_scope" {
  description = "OAuth2 scope"
}

variable "oauth_mesh_enabled" {
  type        = bool
  default     = true
  description = "OAuth2 inside service mesh via Envoy filter"
}

variable "oauth_oidc_jwks_url" {
  type        = string
  default     = ""
  description = "Remote jwks url"
}

variable "oauth_oidc_host" {
  type        = string
  default     = ""
  description = "OIDC FQDN name"
}

variable "oauth_oidc_port" {
  type        = number
  default     = 443
  description = "OIDC service port"
}

variable "oauth_local_jwks" {
  type        = string
  default     = ""
  description = "local jwks"
}

##########################
#  Authorization
##########################
variable "authorization_enabled" {
  type        = bool
  default     = true
  description = "Whether authorization module should be deployed"
}

variable "authz_dry_run" {
  type        = bool
  default     = true
  description = "Dry run for forcing authorization policies"
}

variable "authz_uri" {
  type        = string
  default     = ""
  description = "External authorization service uri"
}

variable "opa_policies" {
  type        = map(string)
  default     = {}
  description = "Opa .rego policies"
}

########################
# Istio
########################
variable "istio_namespace" {
  default     = "istio-system"
  description = "istio namespace"
}

########################
# Vault
########################
variable "vault" {
  default = {
    enabled : false
  }
  type = object({
    enabled : bool
  })
  description = "Vault configuration"
}
