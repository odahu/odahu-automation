apiVersion: "acid.zalan.do/v1"
kind: postgresql
metadata:
  name: ${cluster_name}
  namespace: ${namespace}
spec:
  teamId: "${regex("^[[:alnum:]]+", cluster_name)}"
  volume:
    size: ${storage_size}
  numberOfInstances: ${replicas}
  users:
%{ for user in databases ~}
    ${user}: []
%{ endfor ~}
  databases:
%{ for db in databases ~}
    ${db}: ${db}
%{ endfor ~}
  postgresql:
    version: "12"
