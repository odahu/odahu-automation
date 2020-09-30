terraform_version_constraint = ">= 0.12.21"

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))

  cluster_name     = lookup(local.config, "cluster_name", "")
  gcp_project_id   = lookup(lookup(local.config.cloud, "gcp", {}), "project_id", "")
  gcp_region       = lookup(lookup(local.config.cloud, "gcp", {}), "region", "us-east1")
  gcp_zone         = lookup(lookup(local.config.cloud, "gcp", {}), "zone", "us-east1-b")
  gcp_context_name = "gke_${local.gcp_project_id}_${local.gcp_region}_${local.cluster_name}"

  # If "config_context_auth_info", "config_context_cluster" variables are defined in $PROFILE, then we should use it,
  # otherwise we should parse kubeconfig (if exists)
  kubefile                 = fileexists("~/.kube/config") ? file("~/.kube/config") : "{}"
  kubecontexts             = { for context in lookup(yamldecode(local.kubefile), "contexts", []) : lookup(context, "name") => context }
  kube_context_name        = length(local.kubecontexts) > 0 ? lookup(local.kubecontexts[local.gcp_context_name], "name", "") : ""
  kube_context_user        = length(local.kubecontexts) > 0 ? lookup(lookup(local.kubecontexts[local.gcp_context_name], "context", {}), "user", "") : ""
  config_context_auth_info = lookup(local.config, "config_context_auth_info", local.kube_context_name)
  config_context_cluster   = lookup(local.config, "config_context_cluster", local.kube_context_user)
  cluster_domain_name      = lookup(local.config.dns, "domain", null)

  cmd_k8s_config_fetch = "gcloud container clusters get-credentials \"${local.cluster_name}\" --region \"${local.gcp_region}\" --project \"${local.gcp_project_id}\""
}


remote_state {
  backend = "gcs"
  config = {
    bucket      = local.config.tfstate_bucket.tfstate_bucket_name
    credentials = "${get_terragrunt_dir()}/../backend_credentials.json"
    prefix      = basename(get_terragrunt_dir())
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
}

inputs = {
  project_id = local.gcp_project_id
  region     = local.gcp_region
  zone       = local.gcp_zone

  config_context_auth_info = local.config_context_auth_info
  config_context_cluster   = local.config_context_cluster

  cluster_domain_name = local.cluster_domain_name
}
