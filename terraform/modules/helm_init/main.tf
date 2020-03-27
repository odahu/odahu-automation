#########################
# add HELM repositories
#########################
locals {
  helm_repos = {
    stable             = "https://kubernetes-charts.storage.googleapis.com"
    odahuflow          = var.helm_repo
    banzaicloud-stable = "http://kubernetes-charts.banzaicloud.com/branch/master"
  }
}

resource "null_resource" "add_helm_repositories" {
  triggers = {
    repos = join(", ", values(local.helm_repos))
  }

  for_each = local.helm_repos

  provisioner "local-exec" {
    command = "helm repo add ${each.key} ${each.value}"
  }

  provisioner "local-exec" {
    when    = destroy
    command = "helm repo remove ${each.key} || true"
  }
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
