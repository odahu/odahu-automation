locals {
  ingress_tls_secret_name = "odahu-flow-tls"
}

resource "kubernetes_secret" "tls_default" {
  count = length(var.tls_namespaces)
  metadata {
    name      = local.ingress_tls_secret_name
    namespace = element(var.tls_namespaces, count.index)
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type = "kubernetes.io/tls"
}