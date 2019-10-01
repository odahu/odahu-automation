########################################################
# Kubernetes Dashboard
########################################################
data "template_file" "dashboard_values" {
  template = file("${path.module}/templates/dashboard-ingress.yaml")
  vars = {
    cluster_name              = var.cluster_name
    root_domain               = var.root_domain
    dashboard_tls_secret_name = var.dashboard_tls_secret_name
  }
}

resource "helm_release" "kubernetes-dashboard" {
  name      = "kubernetes-dashboard"
  chart     = "stable/kubernetes-dashboard"
  namespace = "kube-system"
  version   = "0.6.8"
  values = [
    data.template_file.dashboard_values.rendered,
  ]
}

resource "kubernetes_secret" "tls_dashboard" {
  metadata {
    name      = var.dashboard_tls_secret_name
    namespace = "kube-system"
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type = "kubernetes.io/tls"
}