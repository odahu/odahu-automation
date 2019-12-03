output "helm_values" {
  value = {
    "controller.service.type"                                                                            = "LoadBalancer"
    "controller.service.loadBalancerIP"                                                                  = data.azurerm_public_ip.ingress.ip_address
    "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group" = tostring(var.aks_ip_resource_group)
  }
}