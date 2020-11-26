terraform_version_constraint = ">= 0.13.4"

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))

  cluster_name   = lookup(local.config, "cluster_name", "")
  vpc_name       = lookup(local.config, "vpc_name", "${local.cluster_name}-vpc")
  gcp_project_id = lookup(lookup(local.config.cloud, "gcp", {}), "project_id", "")
  gcp_region     = lookup(lookup(local.config.cloud, "gcp", {}), "region", "us-east1")
  gcp_zone       = lookup(lookup(local.config.cloud, "gcp", {}), "zone", "us-east1-b")
  node_locations = lookup(lookup(local.config.cloud, "gcp", {}), "node_locations", [])

  google_credentials  = replace(replace(lookup(local.config.cloud.gcp.credentials, "GOOGLE_CREDENTIALS", {}), "\"", "\\\""), "\\n", "\\\\n")
  gke_backend_credentials = lookup(local.config.tfstate_bucket, "credentials", "") == "" ? local.google_credentials : replace(replace(lookup(local.config.tfstate_bucket, "credentials", {}), "\"", "\\\""), "\\n", "\\\\n")

  scripts_dir             = "${get_terragrunt_dir()}/../../../../../scripts"
  cmd_k8s_fwrules_cleanup = "${local.scripts_dir}/gcp_k8s_fw_cleanup.sh"
  cmd_k8s_config_fetch    = "gcloud container clusters get-credentials \"${local.cluster_name}\" --region \"${local.gcp_region}\" --project \"${local.gcp_project_id}\""
}

remote_state {
  backend = "gcs"
  config  = {
    bucket      = local.config.tfstate_bucket.tfstate_bucket_name
    credentials = "/tmp/gke_backend_credentials.json"
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

  after_hook "pass_gke_backend_credentials" {
    commands = ["terragrunt-read-config"]
    execute  = ["bash", "-c", "echo ${local.gke_backend_credentials} > /tmp/gke_backend_credentials.json"]
  }

  after_hook "k8s_fwrules_cleanup" {
    commands = ["destroy"]
    execute  = ["bash", local.cmd_k8s_fwrules_cleanup, local.vpc_name, local.gcp_project_id]
  }

  after_hook "k8s_config_fetch" {
    commands     = ["apply"]
    execute      = ["bash", "-c", local.cmd_k8s_config_fetch]
    run_on_error = false
  }

  after_hook "remove_gke_backend_credentials" {
    commands = [
      "apply",
      "plan",
      "output",
      "destroy"
    ]
    execute = ["bash", "-c", "rm -f /tmp/gke_backend_credentials.json"]
    run_on_error = true
  }
}

inputs = {
  project_id     = local.gcp_project_id
  region         = local.gcp_region
  zone           = local.gcp_zone
  node_locations = local.node_locations
}
