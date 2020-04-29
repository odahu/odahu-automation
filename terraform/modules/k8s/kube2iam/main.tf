locals {
  aws_resource_count = var.cluster_type == "aws/eks" ? 1 : 0
}

data "template_file" "kube2iam_values" {
  count    = local.aws_resource_count
  template = file("${path.module}/templates/kube2iam.yaml")
  vars = {
    cluster_type = var.cluster_type
    image_tag    = var.image_tag
    image_repo   = var.image_repo
  }
}

resource "helm_release" "kube2iam" {
  count         = local.aws_resource_count
  name          = "kube2iam"
  chart         = "stable/kube2iam"
  version       = var.chart_version
  force_update  = true
  recreate_pods = true
  timeout       = var.helm_timeout

  values = [
    data.template_file.kube2iam_values[0].rendered,
  ]
}
