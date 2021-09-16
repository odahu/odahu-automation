terraform_version_constraint = ">= 0.13.4"

locals {
  profile = get_env("PROFILE", "${get_terragrunt_dir()}//profile.json")
  config  = jsondecode(file(local.profile))

  cluster_name     = lookup(local.config, "cluster_name", "odahuflow")
  aws_region       = lookup(lookup(local.config.cloud, "aws", {}), "region", "eu-central-1")
  az_list          = lookup(lookup(local.config.cloud, "aws", {}), "az_list", [])
  kms_key_arn      = lookup(lookup(local.config.cloud, "aws", {}), "kms_key_arn", "")
  remain_pv_drives = lookup(local.config, "remain_pv_drives", "")

  scripts_dir           = "${get_terragrunt_dir()}/../../../../../scripts"
  cmd_aws_delete_drives = "${local.scripts_dir}/destroy_aws_pv.sh"
  cmd_k8s_config_fetch  = "aws eks update-kubeconfig --name \"${local.cluster_name}\" --region \"${local.aws_region}\""
}

remote_state {
  backend = "s3"
  config = {
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

  after_hook "k8s_config_fetch" {
    commands     = ["apply"]
    execute      = ["bash", "-c", local.cmd_k8s_config_fetch]
    run_on_error = false
  }

  after_hook "k8s_disks_cleanup" {
    commands = ["destroy"]
    execute  = ["bash", local.cmd_aws_delete_drives, local.cluster_name, local.remain_pv_drives]
  }
}

inputs = {
  aws_region   = local.aws_region
  az_list      = local.az_list
  cluster_name = local.cluster_name
  kms_key_arn  = local.kms_key_arn
}
