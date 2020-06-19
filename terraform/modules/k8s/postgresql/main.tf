locals {
  helm_repo    = "postgres-operator"
  helm_version = "1.5.0"

  kube_pg_status_cmd = "kubectl -n ${var.namespace} get postgresql ${var.configuration.cluster_name} -ojsonpath='{.status.PostgresClusterStatus}'"
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
  namespace  = var.namespace
  timeout    = var.helm_timeout
  depends_on = [kubernetes_namespace.pgsql[0]]
}

resource "local_file" "pg_cluster" {
  count = var.configuration.enabled ? 1 : 0
  content = templatefile("${path.module}/templates/pg_crd_manifest.tpl", {
    namespace    = var.namespace
    storage_size = var.configuration.storage_size
    replicas     = var.configuration.replica_count
    cluster_name = var.configuration.cluster_name
    databases    = var.databases
  })
  filename = "/tmp/.odahu/pg_crd_manifest.yml"

  file_permission      = 0644
  directory_permission = 0755

  depends_on = [helm_release.pg_operator[0]]
}

resource "null_resource" "pg_cluster" {
  count = var.configuration.enabled ? 1 : 0
  provisioner "local-exec" {
    interpreter = ["timeout", "1m", "bash", "-c"]

    command = "until kubectl apply -f ${local_file.pg_cluster[0].filename}; do sleep 5; done"
  }
  depends_on = [local_file.pg_cluster[0]]
}

resource "null_resource" "pg_cluster_check" {
  count = var.configuration.enabled ? 1 : 0

  provisioner "local-exec" {
    interpreter = ["timeout", "5m", "bash", "-c"]

    command = "until [[ $(${local.kube_pg_status_cmd}) = 'Running' ]]; do sleep 5; done"
  }
  depends_on = [null_resource.pg_cluster[0]]
}

data "kubernetes_secret" "pg" {
  for_each = toset(var.databases)
  metadata {
    name      = "${each.key}.${var.configuration.cluster_name}.credentials.postgresql.acid.zalan.do"
    namespace = var.namespace
  }
  depends_on = [null_resource.pg_cluster_check[0]]
}
