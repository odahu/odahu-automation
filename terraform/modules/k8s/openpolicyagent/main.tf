resource "kubernetes_namespace" "opa" {
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
  depends_on = [var.module_dependency]
}

resource "helm_release" "opa" {
  name       = "odahu-flow-opa"
  chart      = "odahu-flow-opa"
  version    = var.odahu_infra_version
  namespace  = var.namespace
  repository = "odahuflow"
  timeout    = var.helm_timeout
  depends_on = [
    kubernetes_namespace.opa,
    var.module_dependency
  ]
  values = [
    templatefile("${path.module}/templates/values.yaml", {
      authorization_enabled = var.authorization_enabled
      authz_dry_run         = var.authz_dry_run
      authz_uri             = var.authz_uri
      oauth_mesh_enabled    = var.oauth_mesh_enabled
      oauth_oidc_jwks_url   = var.oauth_oidc_jwks_url
      oauth_oidc_issuer_url = var.oauth_oidc_issuer_url
      oauth_oidc_host       = var.oauth_oidc_host
      oauth_oidc_port       = var.oauth_oidc_port
      oauth_local_jwks      = base64decode(var.oauth_local_jwks)
      opa_policies          = yamlencode({ policies = var.opa_policies })
    })
  ]
}
