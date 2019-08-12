########################################################
# Common variables
########################################################
# set GOOGLE_CREDENTIALS=/path/to/creds/.json or enable the property below
# gcp_credentials             = "/Users/alex/Work/legion/secrets/gcp-epmd-legn-legion-automation.json"
cluster_name                = "gke-legion-demo"
region                      = "us-east1"
zone                        = "us-east1-b"
root_domain                 = "gcp.epm.kharlamov.biz"
secrets_storage             = "epm-legion-gcp-storage"
aws_profile                 = "bdcc"
config_context_auth_info    = "gke_or2-msq-epmd-legn-t1iylu_us-east1-b_gke-legion-demo"
config_context_cluster      = "gke_or2-msq-epmd-legn-t1iylu_us-east1-b_gke-legion-demo"
aws_vpc_id                  = "vpc-5729c13e"
network_name                = "gke-legion-demo-vpc"
bastion_tag                 = "gke-legion-demo-bastion"
gke_node_tag                = "gke-legion-demo-gke-node"

########################################################
# GKE module
########################################################
location                    = "us-east1-b"
dns_zone_name               = "legion"

########################################################
# Common Legion variables
########################################################
legion_helm_repo            = "https://raw.githubusercontent.com/legion-platform/legion-helm-charts/master/"
docker_repo                 = "registry.hub.docker.com/legionplatformtest"
cluster_context             = "gke_or2-msq-epmd-legn-t1iylu_us-east1-b_gke-legion-demo"
legion_infra_version        = "1.0.0-rc8"


########################################################
# Authorization and authentication
########################################################
keycloak_url                = "https://keycloak.epm.kharlamov.biz"
keycloak_realm              = "legion-cluster"
keycloak_realm_audience     = "legion-cluster"

########################################################
# Legion
########################################################
legion_version            = "1.0.0-rc12"
legion_data_bucket        = "gke-legion-demo-data-store"
