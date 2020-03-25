terraform_version_constraint = ">= 0.12.21"

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))

  cluster_name        = lookup(local.config, "cluster_name", "")
  aws_region          = lookup(lookup(local.config.cloud, "aws", {}), "region", "eu-central-1")
  az_list             = lookup(lookup(local.config.cloud, "aws", {}), "az_list", [])
  cluster_domain_name = lookup(local.config.dns, "domain", null)
  context_name        = "arn:aws:eks:${local.aws_region}:505502776526:cluster/${local.cluster_name}"

  # If "config_context_auth_info", "config_context_cluster" variables are defined in $PROFILE, then we should use it,
  # otherwise we should parse kubeconfig (if exists)
  kubefile                 = fileexists("~/.kube/config") ? file("~/.kube/config") : "{}"
  kubecontexts             = { for context in lookup(yamldecode(local.kubefile), "contexts", []) : lookup(context, "name") => context }
  kube_context_name        = length(local.kubecontexts) > 0 ? lookup(local.kubecontexts[local.context_name], "name", "") : ""
  kube_context_user        = length(local.kubecontexts) > 0 ? lookup(lookup(local.kubecontexts[local.context_name], "context", {}), "user", "") : ""
  config_context_auth_info = lookup(local.config, "config_context_auth_info", local.kube_context_name)
  config_context_cluster   = lookup(local.config, "config_context_cluster", local.kube_context_user)
}

remote_state {
  backend = "s3"
  config = {
    bucket = local.config.tfstate_bucket
    region = local.aws_region
    key    = "${basename(get_terragrunt_dir())}/default.tfstate"
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
  aws_region          = local.aws_region
  az_list             = local.az_list
  cluster_domain_name = local.cluster_domain_name

  config_context_auth_info = local.config_context_auth_info
  config_context_cluster   = local.config_context_cluster
}
