locals {
  drivers_yaml  = "${path.module}/files/cos-nvidia-driver-installer.yaml"
  exporter_yaml = "/tmp/.odahu/nvidia_exporter.yml"
}

# Daemonset config for GCP Container-Optimized OS
# from https://github.com/GoogleCloudPlatform/container-engine-accelerators/blob/master/nvidia-driver-installer/cos/daemonset-preloaded.yaml
resource "null_resource" "nvidia_drivers" {
  triggers = {
    manifest = filemd5(local.drivers_yaml)
  }
  provisioner "local-exec" {
    command = "kubectl apply -f ${local.drivers_yaml} -n ${var.namespace}"
  }
}

resource "local_file" "nvidia_exporter_yaml" {
  content = templatefile("${path.module}/templates/nvidia-exporter.tpl", {
    namespace      = var.monitoring_namespace,
    exporter_image = var.exporter_image,
    exporter_tag   = var.exporter_tag,
    exporter_port  = var.exporter_port
  })
  filename = local.exporter_yaml

  file_permission      = 0644
  directory_permission = 0755
}

resource "null_resource" "nvidia_exporter" {
  provisioner "local-exec" {
    command = "kubectl apply -f ${local.exporter_yaml} -n ${var.monitoring_namespace}"
  }
  depends_on = [
    var.module_dependency,
    local_file.nvidia_exporter_yaml
  ]
}

resource "kubernetes_config_map" "grafana_dashboard" {
  metadata {
    annotations = {
      k8s-sidecar-target-directory = "/tmp/dashboards/k8s"
    }
    labels = {
      grafana_dashboard = "1"
    }
    name      = "gpu-dashboard.json"
    namespace = var.monitoring_namespace
  }

  data = {
    "gpu-dashboard.json" = file("${path.module}/files/grafana-gpu-dashboard.json.dashboard")
  }

  depends_on = [
    null_resource.nvidia_exporter
  ]
}
