locals {
  kubeconfig               = fileexists("~/.kube/config") ? yamldecode(file("~/.kube/config")) : null
  config_context_auth_info = var.config_context_auth_info == "" ? local.kubeconfig.contexts[0].name : var.config_context_auth_info
  config_context_cluster   = var.config_context_cluster == "" ? local.kubeconfig.contexts[0].context.user : var.config_context_cluster

  network_name = var.vpc_name == "" ? "${var.cluster_name}-vpc" : var.vpc_name

  cluster_domain_name = lookup(var.dns, "domain", null)
}
