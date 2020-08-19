resource "helm_release" "nginx-ingress" {
  name       = "nginx-ingress"
  repository = var.helm_repo
  chart      = "nginx-ingress"
  namespace  = "kube-system"
  version    = "1.36.3"
  wait       = false

  set {
    name  = "controller.config.proxy-buffer-size"
    value = "256k"
  }

  dynamic "set" {
    iterator = elem
    for_each = var.helm_values
    content {
      name  = elem.key
      value = elem.value
    }
  }

  depends_on = [var.dependencies]
}
