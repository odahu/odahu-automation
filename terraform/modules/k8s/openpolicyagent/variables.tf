variable "helm_repo" {
  type        = string
  description = "ODAHU flow helm repo"
}

variable "helm_timeout" {
  type        = number
  default     = 600
  description = "Helm chart deploy timeout in seconds"
}

variable "odahu_infra_version" {
  type        = string
  description = "ODAHU flow infra release version"
}

variable "namespace" {
  type        = string
  default     = "odahu-flow-opa"
  description = "Open Policy Agent namespace"
}

variable "module_dependency" {
  type        = any
  default     = null
  description = "Dependency of this module (https://discuss.hashicorp.com/t/tips-howto-implement-module-depends-on-emulation/2305)"
}

variable "oauth_oidc_issuer_url" {
  type        = string
  default     = ""
  description = "Oauth OIDC Issuer url"
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

variable "authorization_enabled" {
  type        = bool
  default     = true
  description = "Whether external authorization module should be deployed"
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

variable "authz_certs" {
  description = "Certs from webhook server that injects opa sidecars"
  type = object({
    cert = string
    key  = string
    ca   = string
  })
}

variable "opa_policies" {
  type        = map(string)
  default     = {}
  description = "Opa .rego policies"
}
