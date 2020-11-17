terraform_version_constraint = ">= 0.13.4"

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))

  cluster_name = lookup(local.config, "cluster_name", "")
  vpc_name     = lookup(local.config, "vpc_name", "${local.cluster_name}-vpc")
  subnet_name  = lookup(local.config, "subnet_name", "${local.cluster_name}-subnet")

  resource_group  = lookup(lookup(local.config.cloud, "azure", {}), "resource_group", "")
  location        = lookup(lookup(local.config.cloud, "azure", {}), "location", "")
  storage_account = lookup(lookup(local.config.cloud, "azure", {}), "storage_account", "")

  config_context_auth_info = lookup(local.config, "config_context_auth_info", "")
  config_context_cluster   = lookup(local.config, "config_context_cluster", "")
  cluster_domain_name      = lookup(local.config.dns, "domain", null)

  dns_zone      = replace(local.cluster_domain_name, "/^[a-zA-Z0-9-_]+\\./", "")
  records       = lookup(local.config.dns, "records", get_env("TF_VAR_records", "[]"))
  records_str   = join(" ", [for rec in jsondecode(local.records) : "${rec.name}:${rec.value}" if rec.value != "null"])
  scripts_dir   = "${get_terragrunt_dir()}/../../../../../scripts"
  cmd_check_dns = "${local.scripts_dir}/check_dns.sh"

  cmd_k8s_config_fetch = "az aks get-credentials --overwrite-existing --name \"${local.cluster_name}\" --resource-group \"${local.resource_group}\""

  gcp_credentials     = get_env("GOOGLE_CREDENTIALS", lookup(lookup(lookup(local.config.cloud, "gcp", {}), "credentials", {}), "GOOGLE_CREDENTIALS", ""))
  gcp_project_id      = lookup(lookup(local.config.cloud, "gcp", {}), "project_id", "")
  gcp_dns_credentials = lookup(local.config.dns, "gcp_credentials", local.gcp_credentials)
  gcp_dns_project_id  = lookup(local.config.dns, "gcp_project_id", local.gcp_project_id)
}

remote_state {
  backend = "azurerm"
  config = {
    container_name       = local.config.tfstate_bucket.tfstate_bucket_name
    resource_group_name  = local.resource_group
    storage_account_name = local.storage_account
    key                  = "${basename(get_terragrunt_dir())}/default.tfstate"
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

  after_hook "check_dns" {
    commands     = ["apply"]
    execute      = ["bash", local.cmd_check_dns, local.dns_zone, local.records_str]
    run_on_error = false
  }

  before_hook "k8s_config_fetch" {
    commands = ["destroy"]
    execute  = ["bash", "-c", local.cmd_k8s_config_fetch]
  }
}

inputs = {
  azure_resource_group  = local.resource_group
  azure_location        = local.location
  azure_storage_account = local.storage_account

  config_context_auth_info = local.config_context_auth_info
  config_context_cluster   = local.config_context_cluster

  vpc_name    = local.vpc_name
  subnet_name = local.subnet_name

  records         = local.records
  managed_zone    = lookup(local.config.dns, "zone_name", "")
  domain          = local.cluster_domain_name
  gcp_project_id  = local.gcp_dns_project_id
  gcp_credentials = local.gcp_dns_credentials
}
