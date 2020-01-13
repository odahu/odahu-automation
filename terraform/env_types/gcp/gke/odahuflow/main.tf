########################################################
# Odahuflow setup
########################################################

locals {
  pools  = {for pool in keys(var.node_pools) :  lookup(lookup(var.node_pools[pool], "labels", {}), "mode", "") => var.node_pools[pool] if lookup(lookup(var.node_pools[pool], "labels", {}), "mode", "") != "" }
}

module "odahuflow_prereqs" {
  source       = "../../../../modules/odahuflow/prereqs/gke"
  project_id   = var.project_id
  region       = var.region
  cluster_name = var.cluster_name
  data_bucket  = var.data_bucket
}

module "fluentd" {
  source = "../../../../modules/k8s/fluentd"

  docker_repo         = var.docker_repo
  odahu_infra_version = var.odahu_infra_version

  extra_helm_values = module.odahuflow_prereqs.fluent_helm_values
}

module "jupyterhub" {
  source = "../../../../modules/k8s/jupyterhub"

  jupyterhub_enabled = var.jupyterhub_enabled
  cluster_domain     = "odahu.${var.cluster_name}.${var.root_domain}"
  tls_secret_crt     = var.tls_crt
  tls_secret_key     = var.tls_key

  docker_repo = var.docker_repo
  docker_tag  = var.jupyterlab_version

  oauth_client_id       = var.oauth_client_id
  oauth_client_secret   = var.oauth_client_secret
  oauth_oidc_issuer_url = var.oauth_oidc_issuer_url
}

module "odahuflow_helm" {
  source = "../../../../modules/odahuflow/helm"

  tls_secret_crt = var.tls_crt
  tls_secret_key = var.tls_key
  cluster_domain = "odahu.${var.cluster_name}.${var.root_domain}"

  model_training_nodes   = contains(keys(local.pools), "odahu-flow-training") ? { node_selector = { mode = local.pools["odahu-flow-training"].labels["mode"] }, toleration = { Key = local.pools["odahu-flow-training"].taints[0].key, Operator = "Equal", Value = local.pools["odahu-flow-training"].taints[0].value, Effect = replace(title(lower(replace(local.pools["odahu-flow-training"].taints[0].effect, "_", " "))), " ", "") }} : { node_selector = null, toleration = null }
  model_packaging_nodes  = contains(keys(local.pools), "odahu-flow-packaging") ? { node_selector = { mode = local.pools["odahu-flow-packaging"].labels["mode"] }, toleration = { Key = local.pools["odahu-flow-packaging"].taints[0].key, Operator = "Equal", Value = local.pools["odahu-flow-packaging"].taints[0].value, Effect = replace(title(lower(replace(local.pools["odahu-flow-packaging"].taints[0].effect, "_", " "))), " ", "") }} : { node_selector = null, toleration = null }
  model_deployment_nodes = contains(keys(local.pools), "odahu-flow-deployment") ? { node_selector = { mode = local.pools["odahu-flow-deployment"].labels["mode"] }, toleration = { Key = local.pools["odahu-flow-deployment"].taints[0].key, Operator = "Equal", Value = local.pools["odahu-flow-deployment"].taints[0].value, Effect = replace(title(lower(replace(local.pools["odahu-flow-deployment"].taints[0].effect, "_", " "))), " ", "") }} : { node_selector = null, toleration = null }

  helm_repo                = var.helm_repo
  docker_repo              = var.docker_repo
  odahuflow_version        = var.odahuflow_version
  packager_version         = var.packager_version
  mlflow_toolchain_version = var.mlflow_toolchain_version

  odahuflow_connections              = concat(var.odahuflow_connections, module.odahuflow_prereqs.odahuflow_connections)
  extra_external_urls                = concat(module.jupyterhub.external_url, module.odahuflow_prereqs.extra_external_urls)
  odahuflow_connection_decrypt_token = var.odahuflow_connection_decrypt_token
}
