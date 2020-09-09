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
  resources:
    limits:
      cpu: "2"
      memory: 2Gi
    requests:
      cpu: 250m
      memory: 256Mi
  sidecars:
    - name: "exporter"
      image: "wrouesnel/postgres_exporter"
      ports:
        - name: exporter
          containerPort: 9187
          protocol: TCP
      resources:
        limits:
          cpu: 500m
          memory: 256M
        requests:
          cpu: 100m
          memory: 200M
      env:
        - name: "PG_EXPORTER_EXCLUDE_DATABASES"
          value: "postgres,template0,template1"
        - name: "PG_EXPORTER_AUTO_DISCOVER_DATABASES"
          value: "true"
        - name: "DATA_SOURCE_URI"
          value: "${cluster_name}:5432/odahu"
        - name: "DATA_SOURCE_USER"
          valueFrom:
            secretKeyRef:
              name: "exporter.${cluster_name}.credentials.postgresql.acid.zalan.do"
              key: username
        - name: "DATA_SOURCE_PASS"
          valueFrom:
            secretKeyRef:
              name: "exporter.${cluster_name}.credentials.postgresql.acid.zalan.do"
              key: password
---
apiVersion: v1
kind: Service
metadata:
  name: pg-exporter
  namespace: ${namespace}
  labels:
    app: pg-exporter
spec:
  ports:
    - name: exporter
      port: 9187
      targetPort: exporter
  selector:
    application: spilo
    team: "${regex("^[[:alnum:]]+", cluster_name)}"
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  namespace: ${namespace}
  name: pg-exporter
  labels:
    app: pg-exporter
    monitoring: prometheus
spec:
  selector:
    matchLabels:
      app: pg-exporter
  endpoints:
  - port: exporter
    path: /metrics
  namespaceSelector:
    matchNames:
    - ${namespace}
---
apiVersion: v1
kind: ConfigMap
metadata:
  name: postgresql-infrastructure-roles
  namespace: ${namespace}
data:
  exporter: |
    inrole: [pg_monitor]
