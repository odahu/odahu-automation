terraform {
  source = "${path_relative_from_include()}/modules//${local.dns_provider}"

  extra_arguments "common_args" {
    commands = [
      "init",
      "apply",
      "plan",
      "destroy"
    ]
    arguments = ["-no-color", "-compact-warnings"]
  }

  after_hook "check_dns" {
    commands     = ["apply"]
    execute      = ["bash", local.cmd_check_dns, local.dns_zone, local.records_str]
    run_on_error = false
  }
}

locals {
  profile      = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config       = jsondecode(file(local.profile))
  cloud_type   = lookup(local.config.cloud, "type", "")
  dns_provider = lookup(local.config.dns, "provider", "gcp")
  cluster_fqdn = lookup(local.config.dns, "domain", "")
  # As long we do not have the root domain in parameters anymore, we assume that dns_zone
  # is 2nd level domain (temporary crutch until terragrunt modules dependencies will be set up)
  dns_zone      = regex("[^.]*\\.[^.]{2,3}(?:\\.[^.]{2,3})?\\.?$", local.cluster_fqdn)
  records       = lookup(local.config.dns, "records", get_env("TF_VAR_records", "[]"))
  records_str   = join(" ", [for rec in jsondecode(local.records) : "${rec.name}:${rec.value}" if rec.value != "null"])
  scripts_dir   = "${get_terragrunt_dir()}/../../../../../scripts"
  cmd_check_dns = "${local.scripts_dir}/check_dns.sh"

  gcp_credentials     = get_env("GOOGLE_CREDENTIALS", lookup(lookup(lookup(local.config.cloud, "gcp", {}), "credentials", {}), "GOOGLE_CREDENTIALS", ""))
  gcp_project_id      = lookup(lookup(local.config.cloud, "gcp", {}), "project_id", "")
  gcp_dns_credentials = lookup(local.config.dns, "gcp_credentials", local.gcp_credentials)
  gcp_dns_project_id  = lookup(local.config.dns, "gcp_project_id", local.gcp_project_id)
}

inputs = {
  records         = local.records
  tfstate_bucket  = local.config.tfstate_bucket
  managed_zone    = lookup(local.config.dns, "zone_name", "")
  domain          = local.cluster_fqdn
  gcp_project_id  = local.gcp_dns_project_id
  gcp_credentials = local.gcp_dns_credentials
}
