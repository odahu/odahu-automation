data "external" "env" {
  program = ["jq", "-n", "env"]
}

locals {
  gcp_credentials = substr(data.external.env.result.GOOGLE_CREDENTIALS, 0, 1) == "{" ? jsondecode(data.external.env.result.GOOGLE_CREDENTIALS) : jsondecode(file(data.external.env.result.GOOGLE_CREDENTIALS))
  gcp_project_id  = length(var.gcp_project_id) == 0 ? local.gcp_credentials.project_id : var.gcp_project_id

  kubeconfig               = yamldecode(file("~/.kube/config"))
  config_context_auth_info = local.kubeconfig.contexts[0].name
  config_context_cluster   = local.kubeconfig.contexts[0].context.user
}
