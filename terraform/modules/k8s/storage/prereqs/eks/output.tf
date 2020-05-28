output "settings" {
  value = {
    parameters = {
      type   = "gp2"
      fsType = "ext4"
    }

    provisioner     = "kubernetes.io/aws-ebs"
    allow_expansion = false
    binding_mode    = "WaitForFirstConsumer"
    reclaim_policy  = "Delete"
  }
}
