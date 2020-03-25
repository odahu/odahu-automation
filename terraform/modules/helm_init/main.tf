#########################
# add HELM repositories
#########################
resource "null_resource" "add_helm_repository_stable" {
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "helm repo add stable https://kubernetes-charts.storage.googleapis.com"
  }
  provisioner "local-exec" {
    when    = destroy
    command = "helm repo rm stable || true"
  }
}

resource "null_resource" "add_helm_repository_odahuflow" {
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "helm repo add odahuflow ${var.helm_repo}"
  }
  depends_on = [null_resource.add_helm_repository_stable]
}

resource "null_resource" "add_helm_repository_istio" {
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "helm repo add istio ${var.istio_helm_repo}"
  }
  depends_on = [null_resource.add_helm_repository_odahuflow]
}

resource "null_resource" "add_helm_vault_repository" {
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "helm repo add banzaicloud-stable http://kubernetes-charts.banzaicloud.com/branch/master"
  }
  depends_on = [null_resource.add_helm_repository_istio]
}

resource "null_resource" "add_helm_bitnami_repository" {
  triggers = {
    build_number = timestamp()
  }
  provisioner "local-exec" {
    command = "helm repo add bitnami https://charts.bitnami.com/bitnami"
  }
  depends_on = [null_resource.add_helm_vault_repository]
}
