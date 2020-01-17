# Daemonset config for GCP Container-Optimized OS
# from https://github.com/GoogleCloudPlatform/container-engine-accelerators/blob/master/nvidia-driver-installer/cos/daemonset-preloaded.yaml
resource "null_resource" "nvidia_drivers" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${path.module}/files/cos-nvidia-driver-installer.yaml"
  }
}
