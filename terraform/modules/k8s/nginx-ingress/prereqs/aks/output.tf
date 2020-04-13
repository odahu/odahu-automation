output "helm_values" {
  value = {
    "controller.service.type"                                                                            = "LoadBalancer"
    "controller.service.loadBalancerIP"                                                                  = azurerm_public_ip.ingress.ip_address
    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group" = var.resource_group
  }
}

output "resource" {
  value = azurerm_public_ip.ingress
}
