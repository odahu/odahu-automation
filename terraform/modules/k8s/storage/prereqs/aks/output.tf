output "settings" {
  value = {
    parameters = {
      kind               = "Managed"
      cachingmode        = "ReadOnly"
      storageaccounttype = "StandardSSD_LRS"
    }

    provisioner     = "kubernetes.io/azure-disk"
    allow_expansion = true
    binding_mode    = "Immediate"
    reclaim_policy  = "Delete"
  }
}
