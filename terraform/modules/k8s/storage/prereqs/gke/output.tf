output "settings" {
  value = {
    parameters = {
      type = "pd-standard"
    }

    provisioner     = "kubernetes.io/gce-pd"
    allow_expansion = true
    binding_mode    = "Immediate"
    reclaim_policy  = "Delete"
  }
}
