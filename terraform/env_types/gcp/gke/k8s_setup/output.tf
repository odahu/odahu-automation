output "helm_values" {
  value = module.nginx_ingress_prereqs.helm_values
}

output "odahu_urls" {
  value = module.odahuflow_helm.odahu_urls
}

output "pg" {
  value = module.postgresql.pgsql_credentials
}

