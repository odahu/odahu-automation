####################
### Distribution ###
####################

variable "helm_repo" {
  description = "Odahuflow helm repo"
}

variable "docker_repo" {
  description = "Odahuflow Docker repo url"
}

variable "odahuflow_version" {
  description = "Odahuflow release version"
}

variable "jupyterlab_version" {
  description = "Jupyterlab version"
}

variable "packager_version" {
  description = "Packager version"
}

variable "mlflow_toolchain_version" {
  description = "Version of odahu-flow-mlflow helm chart"
}

###############
### Ingress ###
###############

variable "cluster_domain" {
  description = "Odahuflow cluster domain"
}

variable "tls_secret_crt" {
  description = "Odahuflow cluster TLS certificate"
  default     = ""
}

variable "tls_secret_key" {
  description = "Odahuflow cluster TLS key"
  default     = ""
}

##################
# Namespaces
##################

variable "odahuflow_namespace" {
  default     = "odahu-flow"
  description = "odahu-flow k8s namespace"
}

variable "odahuflow_training_namespace" {
  default     = "odahu-flow-training"
  description = "odahu-flow training k8s namespace"
}

variable "odahuflow_packaging_namespace" {
  default     = "odahu-flow-packaging"
  description = "odahu-flow packaging k8s namespace"
}

variable "odahuflow_deployment_namespace" {
  default     = "odahu-flow-deployment"
  description = "odahu-flow deployment k8s namespace"
}

variable "vault_namespace" {
  default     = "vault"
  description = "Vault namespace"
}

variable "fluentd_namespace" {
  default     = "fluentd"
  description = "Fluentd namespace"
}

##################
# Odahuflow app
##################

variable "odahuflow_connections" {
  default     = []
  description = "TODO"
}

variable "jupyterhub_enabled" {
  default     = false
  type        = bool
  description = "Flag to install JupyterHub (true) or JupyterLab (false)"
}

##################
# Odahuflow config
##################

variable "extra_external_urls" {
  default = []
  type    = list(object({ name = string, url = string }))
}

variable "connection_repository_type" {
  default = "vault"
}

variable "connection_vault_configuration" {
  type = object({
    secret_engine_path = string
    role               = string
    url                = string
  })
  default = {
    secret_engine_path = "odahu-flow/connections"
    role               = "odahu-flow"
    url                = "https://vault.vault:8200"
  }
}

variable "model_training_nodes" {
  type = object({
    toleration = object({
      Key      = string
      Operator = string
      Value    = string
      Effect   = string
    })
    node_selector = map(string)
  })
  default = {
    toleration = {
      Key      = "dedicated"
      Operator = "Equal"
      Value    = "training"
      Effect   = "NoSchedule"
    }
    node_selector = {
      mode = "odahu-flow-training"
    }
  }
}

variable "model_packaging_nodes" {
  type = object({
    toleration = object({
      Key      = string
      Operator = string
      Value    = string
      Effect   = string
    })
    node_selector = map(string)
  })
  default = {
    toleration = {
      Key      = "dedicated"
      Operator = "Equal"
      Value    = "packaging"
      Effect   = "NoSchedule"
    }
    node_selector = {
      mode = "odahu-flow-packaging"
    }
  }
}

variable "model_deployment_nodes" {
  type = object({
    toleration = object({
      Key      = string
      Operator = string
      Value    = string
      Effect   = string
    })
    node_selector = map(string)
  })
  default = {
    toleration = {
      Key      = "dedicated"
      Operator = "Equal"
      Value    = "deployment"
      Effect   = "NoSchedule"
    }
    node_selector = {
      mode = "odahu-flow-deployment"
    }
  }
}

variable "model_deployment_jws_configuration" {
  type = object({
    enabled = bool
    url     = string
    issuer  = string
  })
  default = {
    enabled = false
    url     = ""
    issuer  = ""
  }
}

# TODO: Remove after implementation of the issue https://github.com/legion-platform/legion/issues/1008
variable "odahuflow_connection_decrypt_token" {
  description = "Token for getting a decrypted connection"
}
