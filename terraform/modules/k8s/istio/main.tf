locals {
  ingress_tls_secret_name = "odahu-flow-tls"

  kubecmd = <<-EOT
    kubectl get crds gateways.networking.istio.io &&
     kubectl get crds envoyfilters.networking.istio.io &&
     kubectl get crds policies.authentication.istio.io &&
     kubectl get crds destinationrules.networking.istio.io &&
     kubectl get crds virtualservices.networking.istio.io &&
     kubectl get crds envoyfilters.networking.istio.io &&
     kubectl get crds attributemanifests.config.istio.io &&
     kubectl get crds handlers.config.istio.io &&
     kubectl get crds meshpolicies.authentication.istio.io
  EOT

  kubecmd_raw = replace(local.kubecmd, "/\\n/", "")
}

resource "kubernetes_namespace" "istio" {
  metadata {
    name = var.istio_namespace
  }
}

resource "kubernetes_secret" "tls_istio" {
  metadata {
    name      = local.ingress_tls_secret_name
    namespace = var.istio_namespace
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type       = "kubernetes.io/tls"
  depends_on = [kubernetes_namespace.istio]
}

resource "null_resource" "istio" {
  provisioner "local-exec" {
    interpreter = ["timeout", "10m", "bash", "-c"]
    command     = "istioctl install -f ../../../../modules/k8s/istio/templates/istio.yaml -y"
  }
  depends_on = [kubernetes_namespace.istio]
}

module "docker_credentials" {
  source          = "../docker_auth"
  docker_repo     = var.docker_repo
  docker_username = var.docker_username
  docker_password = var.docker_password
  namespaces      = [kubernetes_namespace.istio.metadata[0].name]
  sa_list = [
    "istio-ingressgateway-service-account",
    "istio-citadel-service-account",
    "istio-init-service-account",
    "default"
  ]
}
