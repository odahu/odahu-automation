resource "helm_release" "syncer" {
  name          = "syncer"
  chart         = "odahu-flow-syncer"
  version       = var.odahu_infra_version
  namespace     = var.namespace
  force_update  = true
  recreate_pods = true
  repository    = "odahuflow"

  values = [
    var.extra_helm_values
  ]
}
