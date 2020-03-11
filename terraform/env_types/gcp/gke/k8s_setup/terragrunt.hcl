terraform_version_constraint = ">= 0.12.21"

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))

  cluster_name   = lookup(local.config, "cluster_name", "")
  vpc_name       = lookup(local.config, "vpc_name", "${local.cluster_name}-vpc")
  gcp_project_id = lookup(lookup(local.config.cloud, "gcp", {}), "project_id", "")
  gcp_region     = lookup(lookup(local.config.cloud, "gcp", {}), "region", "us-east1")
  gcp_zone       = lookup(lookup(local.config.cloud, "gcp", {}), "zone", "us-east1-b")

  # If "config_context_auth_info", "config_context_cluster" variables are defined in $PROFILE, then we should use it,
  # otherwise we should parse kubeconfig (if exists)
  kubefile                 = fileexists("~/.kube/config") ? file("~/.kube/config") : "{}"
  kubecontexts             = lookup(yamldecode(local.kubefile), "contexts", [])
  kube_context_name        = length(local.kubecontexts) > 0 ? lookup(local.kubecontexts[0], "name", "") : ""
  kube_context_user        = length(local.kubecontexts) > 0 ? lookup(lookup(local.kubecontexts[0], "context", {}), "user", "") : ""
  config_context_auth_info = lookup(local.config, "config_context_auth_info", local.kube_context_name)
  config_context_cluster   = lookup(local.config, "config_context_cluster", local.kube_context_user)
  cluster_domain_name      = lookup(local.config.dns, "domain", null)

  scripts_dir             = "${get_terragrunt_dir()}/../../../../../scripts"
  cmd_k8s_fwrules_cleanup = "${local.scripts_dir}/gcp_k8s_fw_cleanup.sh"
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

  after_hook "k8s_ingress_fwrules_cleanup" {
    commands = ["destroy"]
    execute  = ["bash", "-c", local.cmd_k8s_fwrules_cleanup]
  }
}

inputs = {
  project_id = local.gcp_project_id
  region     = local.gcp_region
  zone       = local.gcp_zone
  vpc_name   = local.vpc_name

  config_context_auth_info = local.config_context_auth_info
  config_context_cluster   = local.config_context_cluster

  cluster_domain_name = local.cluster_domain_name
}
