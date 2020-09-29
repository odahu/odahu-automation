terraform_version_constraint = ">= 0.12.21"

include {
  path = "../../../../modules/dns/terragrunt.hcl"
}

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))
}

remote_state {
  backend = "gcs"
  config = {
    bucket      = local.config.tfstate_bucket.tfstate_bucket_name
    credentials = "${get_terragrunt_dir()}/../backend_credentials.json"
    prefix      = basename(get_terragrunt_dir())
  }
}
