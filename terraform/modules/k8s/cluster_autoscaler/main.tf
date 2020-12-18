#data "aws_iam_role" "node" {
##  name = "tf-${var.cluster_name}-node"
#  name = "tf-${var.cluster_name}-autoscaler"
##tf-${var.cluster_name}-node
#}

#resource "kubernetes_service_account" "example" {
#  metadata {
#    name = "cluster_autoscaler"
#    annotations = []
#  }
#}

resource "helm_release" "autoscaler" {
  name       = "autoscaler"
  chart      = "cluster-autoscaler"
  version    = var.helm_chart_version
  repository = var.helm_repo
  namespace  = "kube-system"
  timeout    = var.helm_timeout

  values = [
    templatefile("${path.module}/templates/cluster_autoscaler.tpl", {
      region        = var.aws_region
      version       = var.autoscaler_version
      iam_role_arn  = var.iam_role_arn
      cluster_name  = var.cluster_name
      cpu_max_limit = var.cpu_max_limit
      mem_max_limit = var.mem_max_limit
    })
  ]
}
