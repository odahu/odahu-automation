locals {
  nginx_service_types = {
    "gcp/gke"   : "LoadBalancer",
    "azure/aks" : "LoadBalancer",
    "aws/eks"   : "NodePort"
  }
}

locals {
  gcp_resource_count = var.cluster_type == "gcp/gke" ? 1 : 0
  azure_resource_count = var.cluster_type == "azure/aks" ? 1 : 0
  aws_resource_count = var.cluster_type == "aws/eks" ? 1 : 0
}

resource "helm_release" "nginx-ingress" {
  name       = "nginx-ingress"
  chart      = "stable/nginx-ingress"
  namespace  = "kube-system"
  version    = "0.25.1"
  wait       = false
  
  set {
    name  = "controller.config.proxy-buffer-size"
    value = "256k"
  }

  # Controller service configuration
  set {
    name  = "controller.service.type"
    value = lookup(local.nginx_service_types, var.cluster_type)
  }

  # GCP GKE only configuration
  dynamic "set" {
    iterator = i
    for_each = local.gcp_resource_count == 0 ? [] : [0]
    content {
      name  = "defaultBackend.service.type"
      value = lookup(local.nginx_service_types, var.cluster_type)
    }
  }

  dynamic "set" {
    iterator = i
    for_each = local.gcp_resource_count == 0 ? [] : [0]
    content {
      name  = "controller.service.loadBalancerIP"
      value = google_compute_address.ingress_lb_address[0].address
    }
  }

  # AWS EKS only configuration
  dynamic "set" {
    iterator = port
    for_each = local.aws_resource_count == 0 ? [] : [30000]
    content {
      name  = "controller.service.nodePorts.http"
      value = port.value
    }
  }

  dynamic "set" {
    iterator = port
    for_each = local.aws_resource_count == 0 ? [] : [30001]
    content {
      name  = "controller.service.nodePorts.https"
      value = port.value
    }
  }

  # Azure AKS only configuration
  dynamic "set" {
    iterator = i
    for_each = local.azure_resource_count == 0 ? [] : [0]
    content {
      name  = "controller.service.loadBalancerIP"
      value = var.aks_ingress_ip
    }
  }

  dynamic "set" {
    iterator = i
    for_each = local.azure_resource_count == 0 ? [] : [0]
    content {
      name  = "controller.service.externalTrafficPolicy"
      value = "Local"
    }
  }

  dynamic "set_string" {
    iterator = i
    for_each = local.azure_resource_count == 0 ? [] : [0]
    content {
      name  = "controller.service.annotations.service\\.beta\\.kubernetes\\.io/azure-load-balancer-resource-group"
      value = var.aks_ip_resource_group
    }
  }
}