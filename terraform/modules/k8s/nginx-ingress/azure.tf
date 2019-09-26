locals {
  azure_resource_count = var.cluster_type == "azure/aks" ? 1 : 0
}

# Enterprise sleep to ensure that load balacer has specific IP address
resource "null_resource" "lb_check" {
  count = local.azure_resource_count
  provisioner "local-exec" {
    command = "timeout 900 bash -c 'until kubectl get -n kube-system svc/nginx-ingress-controller --template=\"{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}\" | grep -E \"^${var.aks_ingress_ip}$\"; do sleep 10; done'"
  }
  depends_on = [helm_release.nginx-ingress]
}