terraform_version_constraint = ">= 0.12.21"

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))

  cluster_name   = lookup(local.config, "cluster_name", "")
  context_name   = lookup(local.config, "config_context", "")
  gcp_project_id = lookup(lookup(local.config.cloud, "gcp", {}), "project_id", "")
  gcp_region     = lookup(lookup(local.config.cloud, "gcp", {}), "region", "us-east1")
  gcp_zone       = lookup(lookup(local.config.cloud, "gcp", {}), "zone", "us-east1-b")
 
  # If "config_context_auth_info", "config_context_cluster" variables are defined in $PROFILE, then we should use it,
  # otherwise we should parse kubeconfig (if exists)
  kubefile         = fileexists("kubeconfig") ? file("kubeconfig") : "{}"
  kube_ctx_name    = local.context_name == "" ? lookup(yamldecode(local.kubefile), "current-context", "") : local.context_name
  kube_ctx_map     = {for context in lookup(yamldecode(local.kubefile), "contexts", []): lookup(context, "name") => context}
  kube_ctx_cluster = length(local.kube_ctx_map) > 0 ? lookup(lookup(local.kube_ctx_map[local.kube_ctx_name], "context", ""), "cluster", "") : ""
  kube_ctx_user    = length(local.kube_ctx_map) > 0 ? lookup(lookup(local.kube_ctx_map[local.kube_ctx_name], "context", ""), "user", "") : ""
  
  cluster_domain_name = lookup(local.config.dns, "domain", null)
}

remote_state {
  backend = "gcs"
  config = {
    bucket = local.config.tfstate_bucket
    prefix = basename(get_terragrunt_dir())
  }
}

terraform {
  extra_arguments "common_args" {
    commands = [
      "init",
      "apply",
      "plan",
      "destroy"
    ]
    arguments = ["-no-color", "-compact-warnings"]
  }
}

inputs = {
  project_id = local.gcp_project_id
  region     = local.gcp_region
  zone       = local.gcp_zone

  config_context           = local.kube_ctx_name
  config_context_auth_info = local.kube_ctx_user
  config_context_cluster   = local.kube_ctx_cluster

  cluster_domain_name = local.cluster_domain_name
}
