terraform_version_constraint = ">= 0.13.4"

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

  dns_zone      = replace(local.cluster_domain_name, "/^[a-zA-Z0-9-_]+\\./", "")
  records       = lookup(local.config.dns, "records", get_env("TF_VAR_records", "[]"))
  records_str   = join(" ", [for rec in jsondecode(local.records) : "${rec.name}:${rec.value}" if rec.value != "null"])
  scripts_dir   = "${get_terragrunt_dir()}/../../../../../scripts"
  cmd_check_dns = "${local.scripts_dir}/check_dns.sh"

  cmd_k8s_config_fetch = "aws eks update-kubeconfig --name \"${local.cluster_name}\" --region \"${local.aws_region}\""

  gcp_credentials     = get_env("GOOGLE_CREDENTIALS", lookup(lookup(lookup(local.config.cloud, "gcp", {}), "credentials", {}), "GOOGLE_CREDENTIALS", ""))
  gcp_project_id      = lookup(lookup(local.config.cloud, "gcp", {}), "project_id", "")
  gcp_dns_credentials = lookup(local.config.dns, "gcp_credentials", local.gcp_credentials)
  gcp_dns_project_id  = lookup(local.config.dns, "gcp_project_id", local.gcp_project_id)
}

remote_state {
  backend = "s3"
  config  = {
    bucket = local.config.tfstate_bucket.tfstate_bucket_name
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
    arguments = [
      "-no-color",
      "-compact-warnings"
    ]
  }

  before_hook "k8s_config_fetch" {
    commands = ["destroy"]
    execute  = ["bash", "-c", local.cmd_k8s_config_fetch]
  }

  after_hook "check_dns" {
    commands     = ["apply"]
    execute      = ["bash", local.cmd_check_dns, local.dns_zone, local.records_str]
    run_on_error = false
  }
}

inputs = {
  records      = local.records
  aws_region   = local.aws_region
  az_list      = local.az_list
  domain       = local.cluster_domain_name
  managed_zone = lookup(local.config.dns, "zone_name", "")

  config_context_auth_info = local.config_context_auth_info
  config_context_cluster   = local.config_context_cluster

  gcp_project_id  = local.gcp_dns_project_id
  gcp_credentials = local.gcp_dns_credentials
}
