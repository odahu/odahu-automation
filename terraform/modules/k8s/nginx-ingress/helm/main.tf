resource "helm_release" "nginx-ingress" {
  name      = "nginx-ingress"
  chart     = "stable/nginx-ingress"
  namespace = "kube-system"
  version   = "0.25.1"
  wait      = false

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
}
