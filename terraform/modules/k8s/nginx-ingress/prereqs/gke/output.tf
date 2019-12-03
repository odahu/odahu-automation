output "helm_values" {
  value = {
    "controller.service.type"                     = "LoadBalancer"
    "defaultBackend.service.type"                 = "ClusterIP"
    "controller.service.loadBalancerIP"           = google_compute_address.ingress_lb_address.address
    "controller.service.loadBalancerSourceRanges" = "{${join(",", formatlist("%s", var.allowed_ips))}}"
  }
}