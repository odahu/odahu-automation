locals {
  helm_chart_version = "0.8.0"
  helm_chart_repo    = "https://raw.githubusercontent.com/kubernetes-sigs/azuredisk-csi-driver/master/charts"
  replicas           = 1

  # https://github.com/Azure/AKS/issues/1075
  # https://github.com/Azure/AKS/issues/118
  # https://stackoverflow.com/a/62567608/895996
  last_applied = jsonencode({
    "apiVersion" = "storage.k8s.io/v1beta1",
    "kind"       = "StorageClass",
    "metadata" = {
      "name"        = "default",
      "annotations" = { "storageclass.beta.kubernetes.io/is-default-class" = "false" },
      "labels"      = { "kubernetes.io/cluster-service" = "true" }
    },
    "parameters" = {
      "cachingmode"        = "ReadOnly",
      "kind"               = "Managed",
      "storageaccounttype" = "StandardSSD_LRS"
    },
    "allowVolumeExpansion" = "true",
    "provisioner"          = "kubernetes.io/azure-disk"
  })

  kube_patch = jsonencode({
    "metadata" = {
      "annotations" = {
        "storageclass.beta.kubernetes.io/is-default-class" = "false",
        "kubectl.kubernetes.io/last-applied-configuration" = local.last_applied
      }
    }
  })

}

resource "helm_release" "azuredisk_csi" {
  name       = "azuredisk-csi-driver"
  chart      = "azuredisk-csi-driver"
  version    = local.helm_chart_version
  namespace  = var.namespace
  repository = local.helm_chart_repo
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/azuredisk_csi.yaml", {
      replicas = local.replicas
    })
  ]
}

resource "kubernetes_storage_class" "odahu" {
  metadata {
    name = var.storage_class_name

    annotations = {
      "storageclass.beta.kubernetes.io/is-default-class" = true
    }
  }
  storage_provisioner = "disk.csi.azure.com"
  reclaim_policy      = "Delete"
  parameters = {
    skuname = "StandardSSD_LRS"
    tags    = "project=odahu-flow,cluster=aks-dev01,env=Development"
  }
  allow_volume_expansion = true
  volume_binding_mode    = "Immediate"

  depends_on = [helm_release.azuredisk_csi]
}

resource "null_resource" "disable_default_sc" {
  provisioner "local-exec" {
    interpreter = ["timeout", "1m", "bash", "-c"]

    command = "kubectl patch storageclass default -p '${local.kube_patch}'"
  }

  depends_on = [null_resource.disable_default_sc]
}
