locals {
  helm_repo    = "postgres-operator"
  helm_version = "1.5.0"
}

resource "kubernetes_namespace" "pgsql" {
  count = var.configuration.enabled ? 1 : 0
  metadata {
    annotations = {
      name = var.namespace
    }
    name = var.namespace
  }
}

resource "helm_release" "pg_operator" {
  count      = var.configuration.enabled ? 1 : 0
  name       = "odahu"
  chart      = "postgres-operator"
  version    = local.helm_version
  repository = local.helm_repo
  namespace  = kubernetes_namespace.pgsql[0].metadata[0].annotations.name
  timeout    = var.helm_timeout
  depends_on = [kubernetes_namespace.pgsql[0]]
}

resource "local_file" "pg_cluster_manifest" {
  count = var.configuration.enabled ? 1 : 0
  content = templatefile("${path.module}/templates/pg_crd_manifest.tpl", {
    namespace    = kubernetes_namespace.pgsql[0].metadata[0].annotations.name
    storage_size = var.configuration.storage_size
    replicas     = var.configuration.replica_count
    cluster_name = var.configuration.cluster_name
    databases    = var.databases
  })
  filename   = "/tmp/pg_crd_manifest.yml"
  depends_on = [helm_release.pg_operator[0]]
}

resource "null_resource" "pg_cluster" {
  count = var.configuration.enabled ? 1 : 0
  provisioner "local-exec" {
    command = "timeout 60 bash -c 'until kubectl apply -f /tmp/pg_crd_manifest.yml; do sleep 5; done'"
  }
  depends_on = [local_file.pg_cluster_manifest[0]]
}
