locals {
  aws_resource_count = var.cluster_type == "aws/eks" ? 1 : 0
}

resource "helm_release" "kube2iam" {
  count         = local.aws_resource_count
  name          = "kube2iam"
  chart         = "kube2iam"
  version       = var.chart_version
  force_update  = true
  recreate_pods = true
  namespace     = var.namespace
  repository    = var.helm_repo
  timeout       = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/kube2iam.yaml", {
      cluster_type = var.cluster_type
      image_tag    = var.image_tag
      image_repo   = var.image_repo
      tolerations  = yamlencode({ tolerations = [{ effect = "NoSchedule", operator = "Exists" }] })
    })
  ]
}
