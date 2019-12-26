output "helm_values" {
  value = module.nginx_ingress_prereqs.helm_values
}

output "load_balancer_ip" {
  value = module.nginx_ingress_prereqs.load_balancer_ip
}
