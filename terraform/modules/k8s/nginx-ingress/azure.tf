data "azurerm_public_ip" "ingress" {
  count               = local.azure_resource_count
  name                = "${var.cluster_name}-ingress"
  resource_group_name = var.aks_ip_resource_group
}

# Enterprise sleep to ensure that load balacer has specific IP address
resource "null_resource" "lb_check" {
  count = local.azure_resource_count
  provisioner "local-exec" {
    command = "timeout 900 bash -c 'until kubectl get -n kube-system svc/nginx-ingress-controller --template=\"{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}\" | grep -E \"^${data.azurerm_public_ip.ingress[0].ip_address}$\"; do sleep 10; done'"
  }
  depends_on = [helm_release.nginx-ingress]
}
