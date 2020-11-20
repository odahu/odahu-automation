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
