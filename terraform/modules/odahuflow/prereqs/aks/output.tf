output "extra_external_urls" {
  value = [
    {
      name     = "Feedback storage"
      url      = "${azurerm_storage_container.odahuflow_bucket.id}/model_log"
      imageUrl = "/img/logo/azure-blob.png"
    }
  ]
}

output "odahu_bucket_name" {
  value = azurerm_storage_container.odahuflow_bucket.name
}

output "odahuflow_connections" {
  sensitive = true
  value = [
    {
      id = "docker-ci"
      spec = {
        type        = "docker"
        username    = local.model_docker_user
        password    = local.model_docker_password
        uri         = local.model_docker_repo
        description = "Default ACR docker repository for model packaging"
        webUILink   = local.model_docker_web_ui_link
      }
    },
    {
      id = "models-output"
      spec = {
        type        = "azureblob"
        keySecret   = "${azurerm_storage_account.odahuflow_data.primary_blob_endpoint}${data.azurerm_storage_account_sas.odahuflow.sas}"
        uri         = "${var.data_bucket}/output"
        description = ""
        webUILink   = "${azurerm_storage_container.odahuflow_bucket.id}/output"
      }
    }
  ]
}

output "fluent_helm_values" {
  value = templatefile("${path.module}/templates/fluentd.yaml", {
    data_bucket             = var.data_bucket
    azure_storage_account   = azurerm_storage_account.odahuflow_data.name
    azure_storage_sas_token = data.azurerm_storage_account_sas.odahuflow.sas
  })
}

output "fluent_daemonset_helm_values" {
  value = {
    config = templatefile("${path.module}/templates/fluentd_ds_cloud.tpl", {
      data_bucket = var.data_bucket
    })

    annotations = {}

    envs = [
      { name = "AZURE_STORAGE_ACCOUNT",
        valueFrom = {
          secretKeyRef = {
            name = "fluentd-secret",
            key  = "AzureStorageAccount"
          }
        }
      },
      { name = "AZURE_STORAGE_SAS_TOKEN",
        valueFrom = {
          secretKeyRef = {
            name = "fluentd-secret",
            key  = "AzureStorageSasToken"
          }
        }
      }
    ]

    secrets = [
      { name  = "AzureStorageAccount",
        value = azurerm_storage_account.odahuflow_data.name
      },
      { name  = "AzureStorageSasToken",
        value = data.azurerm_storage_account_sas.odahuflow.sas
      }
    ]
  }
}

output "logstash_input_config" {
  value = templatefile("${path.module}/templates/logstash.yaml", {
    storage_account_name = azurerm_storage_account.odahuflow_data.name
    storage_access_key   = azurerm_storage_account.odahuflow_data.primary_access_key
    container            = var.data_bucket
  })
}
