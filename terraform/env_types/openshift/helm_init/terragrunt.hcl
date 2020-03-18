terraform_version_constraint = ">= 0.12.21"

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))

  context_name   = lookup(local.config, "config_context_cluster", "")
  oc_url         = lookup(lookup(local.config.cloud, "openshift", {}), "oc_url", "")
  oc_username    = lookup(lookup(local.config.cloud, "openshift", {}), "oc_username", "")
  oc_password    = lookup(lookup(local.config.cloud, "openshift", {}), "oc_password", "")

  # If "config_context_auth_info", "config_context_cluster" variables are defined in $PROFILE, then we should use it,
  # otherwise we should parse kubeconfig (if exists)
  kubefile                 = fileexists("~/.kube/config") ? file("~/.kube/config") : "{}"
  kubecontexts             = {for context in lookup(yamldecode(local.kubefile), "contexts", []): lookup(context, "name") => context}
  kube_context_name        = length(local.kubecontexts) > 0 ? lookup(local.kubecontexts[local.context_name], "cluster", "") : ""
  config_context_auth_info = lookup(local.config, "config_context_auth_info", local.kube_context_name)
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
  config_context_auth_info = local.config_context_auth_info
}
