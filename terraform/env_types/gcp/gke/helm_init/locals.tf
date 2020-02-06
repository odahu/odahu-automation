locals {
  kubeconfig               = yamldecode(file("~/.kube/config"))
  config_context_auth_info = local.kubeconfig.contexts[0].name
  config_context_cluster   = local.kubeconfig.contexts[0].context.user
}
