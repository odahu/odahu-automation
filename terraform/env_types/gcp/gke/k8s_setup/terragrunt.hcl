terraform_version_constraint = ">= 0.13.4"

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))

  cloud_type    = lookup(local.config.cloud, "type", "")
  dns_provider  = lookup(local.config.dns, "provider", "gcp")
  cluster_name  = lookup(local.config, "cluster_name", "")
  cluster_fqdn  = lookup(local.config.dns, "domain", "")
  dns_zone      = replace(local.cluster_fqdn, "/^[a-zA-Z0-9-_]+\\./", "")
  records       = lookup(local.config.dns, "records", get_env("TF_VAR_records", "[]"))
  records_str   = join(" ", [for rec in jsondecode(local.records) : "${rec.name}:${rec.value}" if rec.value != "null"])

  vpc_name         = lookup(local.config, "vpc_name", "${local.cluster_name}-vpc")
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

  google_credentials  = replace(replace(lookup(local.config.cloud.gcp.credentials, "GOOGLE_CREDENTIALS", {}), "\"", "\\\""), "\\n", "\\\\n")
  gke_backend_credentials = lookup(local.config.tfstate_bucket, "credentials", "") == "" ? local.google_credentials : replace(replace(lookup(local.config.tfstate_bucket, "credentials", {}), "\"", "\\\""), "\\n", "\\\\n")

  scripts_dir             = "${get_terragrunt_dir()}/../../../../../scripts"
  cmd_k8s_fwrules_cleanup = "${local.scripts_dir}/gcp_k8s_fw_cleanup.sh"
  cmd_k8s_config_fetch    = "gcloud container clusters get-credentials \"${local.cluster_name}\" --region \"${local.gcp_region}\" --project \"${local.gcp_project_id}\""
  cmd_check_dns           = "${local.scripts_dir}/check_dns.sh"
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

  after_hook "check_dns" {
    commands     = ["apply"]
    execute      = ["bash", local.cmd_check_dns, local.dns_zone, local.records_str]
    run_on_error = false
  }

  before_hook "k8s_config_fetch" {
    commands = ["destroy"]
    execute  = ["bash", "-c", local.cmd_k8s_config_fetch]
  }

  after_hook "k8s_ingress_fwrules_cleanup" {
    commands = ["destroy"]
    execute  = ["bash", "-c", local.cmd_k8s_fwrules_cleanup]
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
  project_id = local.gcp_project_id
  region     = local.gcp_region
  zone       = local.gcp_zone
  vpc_name   = local.vpc_name
  records    = local.records

  config_context_auth_info = local.config_context_auth_info
  config_context_cluster   = local.config_context_cluster

  cluster_domain_name = local.cluster_domain_name
  managed_zone        = lookup(local.config.dns, "zone_name", "")
  domain              = local.cluster_fqdn
}
