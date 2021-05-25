output "external_url" {
  value = var.configuration.enabled ? [
    {
      name     = "Argo Workflows",
      url      = "${local.url_schema}://${var.cluster_domain}/argo/",
      imageUrl = "/img/logo/argo.png"
    }
  ] : []
}
