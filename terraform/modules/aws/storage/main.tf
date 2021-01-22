resource "local_file" "storage_class" {
  content = templatefile("${path.module}/templates/storage-class.tpl", {
    kms_key_arn        = var.kms_key_arn
    storage_class_name = var.storage_class_name
    fs_type            = var.fs_type
    storage_type       = var.storage_type
  })
  filename = "/tmp/.odahu/storage_class.yml"

  file_permission      = 0644
  directory_permission = 0755
}

resource "null_resource" "create_encrypted_storage_class" {
  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    command = "timeout 90 bash -c 'until kubectl apply -f ${local_file.storage_class.filename}; do sleep 5; done'"
  }
}

resource "null_resource" "set_default_storage_class" {
  triggers = {
    build_number = timestamp()
  }

  provisioner "local-exec" {
    command = "bash ../../../../../scripts/set_default_storage_class.sh \"${var.storage_class_name}\""
  }

  depends_on = [null_resource.create_encrypted_storage_class]
}

