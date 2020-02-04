locals {
  ingress_tls_secret_name = "odahu-flow-tls"
  dockerconfigjson = (length(var.docker_username) != 0 && length(var.docker_password) != 0) ? {
    "auths": {
      "${var.docker_repo}" = {
        email    = "admin@odahu.com"
        username = var.docker_username
        password = var.docker_password
        auth     = base64encode(join(":",[var.docker_username, var.docker_password]))
      }
    }
  } : {}
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

resource "kubernetes_secret" "docker_credentials" {
  count = local.dockerconfigjson != {} ? 1 : 0
  metadata {
    name      = "repo-json-key"
    namespace = var.istio_namespace
  }
  data = {
    ".dockerconfigjson" = jsonencode(local.dockerconfigjson)
  }
  type       = "kubernetes.io/dockerconfigjson"
  depends_on = [kubernetes_namespace.istio]
}

resource "helm_release" "istio-init" {
  name       = "istio-init"
  chart      = "istio/istio-init"
  version    = var.istio_version
  namespace  = var.istio_namespace
  repository = "istio"
  depends_on = [kubernetes_namespace.istio]
}

resource "null_resource" "delay" {
  provisioner "local-exec" {
    command = "timeout 200 bash -c 'until $(kubectl get --all-namespaces gateways.networking.istio.io && kubectl get --all-namespaces envoyfilters.networking.istio.io && kubectl get --all-namespaces policies.authentication.istio.io && kubectl get --all-namespaces destinationrules.networking.istio.io && kubectl get --all-namespaces virtualservices.networking.istio.io && kubectl get --all-namespaces envoyfilters.networking.istio.io && kubectl get --all-namespaces attributemanifests.config.istio.io && kubectl get --all-namespaces handlers.config.istio.io && kubectl get --all-namespaces meshpolicies.authentication.istio.io); do sleep 5; done'"
  }
  depends_on = [helm_release.istio-init]
}

data "template_file" "istio_values" {
  template = file("${path.module}/templates/istio.yaml")
  vars = {
    cluster_name            = var.cluster_name
    root_domain             = var.root_domain
    monitoring_namespace    = var.monitoring_namespace
    ingress_tls_secret_name = local.ingress_tls_secret_name
  }
}

resource "helm_release" "istio" {
  name       = "istio"
  chart      = "istio/istio"
  version    = var.istio_version
  namespace  = var.istio_namespace
  repository = "istio"
  timeout    = "600"

  values = [
    data.template_file.istio_values.rendered,
  ]

  depends_on = [null_resource.delay]
}

resource "kubernetes_namespace" "knative" {
  metadata {
    name = var.knative_namespace
    labels = {
      istio-injection = "enabled"
    }
  }
}

resource "kubernetes_secret" "tls_knative" {
  metadata {
    name      = local.ingress_tls_secret_name
    namespace = var.knative_namespace
  }
  data = {
    "tls.key" = var.tls_secret_key
    "tls.crt" = var.tls_secret_crt
  }
  type       = "kubernetes.io/tls"
  depends_on = [kubernetes_namespace.knative]
}

resource "null_resource" "set_default_namespace_docker_secret" {
  provisioner "local-exec" {
    command = "for i in istio-ingressgateway-service-account istio-citadel-service-account istio-init-service-account default; do kubectl patch serviceaccount -n ${var.istio_namespace} $i -p '{\"imagePullSecrets\": [{\"name\": \"repo-json-key\"}]}';done"
  }
  depends_on = [kubernetes_namespace.istio, kubernetes_secret.docker_credentials, helm_release.istio-init, helm_release.istio]
}

resource "helm_release" "knative" {
  name       = "knative"
  chart      = "odahu-flow-knative"
  version    = var.odahu_infra_version
  namespace  = var.knative_namespace
  repository = "odahuflow"
  depends_on = [kubernetes_namespace.knative, helm_release.istio]
}
