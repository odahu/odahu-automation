output "extra_external_urls" {
  value = [
    {
      name     = "Feedback storage"
      url      = "${azurerm_storage_container.odahuflow_data_bucket.id}/model_log"
      imageUrl = "/img/logo/azure-blob.png"
    }
  ]
}

output "odahu_data_bucket_name" {
  value = azurerm_storage_container.odahuflow_data_bucket.name
}

output "odahu_log_bucket_name" {
  value = var.log_bucket == "" ? "" : azurerm_storage_container.odahuflow_log_bucket[0].name
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
        vital       = true
      }
    },
    {
      id = "models-output"
      spec = {
        type        = "azureblob"
        keySecret   = base64encode("${azurerm_storage_account.odahuflow_data.primary_blob_endpoint}${data.azurerm_storage_account_sas.odahuflow_data.sas}")
        uri         = "${var.data_bucket}/output"
        description = ""
        webUILink   = "${azurerm_storage_container.odahuflow_data_bucket.id}/output"
        vital       = true
      }
    }
  ]
}

output "fluent_helm_values" {
  value = templatefile("${path.module}/templates/fluentd.yaml", {
    data_bucket             = var.data_bucket
    azure_storage_account   = azurerm_storage_account.odahuflow_data.name
    azure_storage_sas_token = data.azurerm_storage_account_sas.odahuflow_data.sas
    fluentd                 = yamlencode(local.fluentd)
  })
}

output "fluent_daemonset_helm_values" {
  value = {
    config = templatefile("${path.module}/templates/fluentd_ds_cloud.tpl", {
      data_bucket = local.log_bucket
    })

    annotations    = {}
    sa_annotations = {}

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
        value = local.log_storage_account
      },
      { name  = "AzureStorageSasToken",
        value = local.log_sas_token
      }
    ]
  }
}

output "logstash_input_config" {
  value = templatefile("${path.module}/templates/logstash.yaml", {
    storage_account_name = local.log_storage_account
    storage_access_key   = local.log_storage_access_key
    container            = local.log_bucket
  })
}

output "jupyterhub_cloud_settings" {
  value = {
    type = "azure",
    settings = {
      account_name = azurerm_storage_account.odahuflow_data.name
      sas_token    = data.azurerm_storage_account_sas.odahuflow_data.sas
    }
  }
}
