output "helm_values" {
  value = {
    "controller.service.type"            = "NodePort"
    "controller.service.nodePorts.http"  = 30000
    "controller.service.nodePorts.https" = 30001
  }
}