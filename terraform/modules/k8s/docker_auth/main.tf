locals {
  dockerconfigjson = (length(var.docker_username) != 0 && length(var.docker_password) != 0) ? {
    "auths" : {
      "${var.docker_repo}" = {
        email    = "admin@odahu.org"
        username = var.docker_username
        password = var.docker_password
        auth     = base64encode(join(":", [var.docker_username, var.docker_password]))
      }
    }
  } : {}
}

resource "kubernetes_secret" "docker_credentials" {
  for_each = toset(var.namespaces)
  metadata {
    name      = var.docker_secret_name
    namespace = each.value
  }
  data = {
    ".dockerconfigjson" = jsonencode(local.dockerconfigjson)
  }
  type = "kubernetes.io/dockerconfigjson"
}

resource "null_resource" "set_default_secret" {
  for_each = toset(var.namespaces)

  provisioner "local-exec" {
    command = "${path.module}/files/set_default_secret.sh \"${var.docker_secret_name}\" \"${each.value}\" \"${tostring(join(" ", var.sa_list))}\" "
  }
  depends_on = [kubernetes_secret.docker_credentials]
}


