output "external_url" {
  value = var.jupyterhub_enabled ? [{
    name      = "JupyterHub",
    url       = "${local.url_schema}://${var.cluster_domain}/jupyterhub",
    image_url = "/img/logo/jupyter.png"
  }] : []
}
