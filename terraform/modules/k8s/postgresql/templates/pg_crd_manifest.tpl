apiVersion: "acid.zalan.do/v1"
kind: postgresql
metadata:
  name: odahu-db
  namespace: ${namespace}
spec:
  teamId: "odahu"
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
