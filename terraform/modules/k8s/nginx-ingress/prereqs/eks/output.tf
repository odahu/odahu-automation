output "helm_values" {
  value = {
    "controller.service.type"            = "NodePort"
    "controller.service.nodePorts.http"  = 30000
    "controller.service.nodePorts.https" = 30001
  }
}

output "load_balancer_ip" {
  value = aws_elb.default.dns_name
}
