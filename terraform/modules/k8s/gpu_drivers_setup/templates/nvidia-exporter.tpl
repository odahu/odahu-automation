---
apiVersion: v1
kind: ServiceAccount
metadata:
  name: nvidia-exporter
  labels:
    app.kubernetes.io/name: dcgm-exporter
    app.kubernetes.io/instance: nvidia-exporter
---
apiVersion: v1
kind: Service
metadata:
  name: nvidia-exporter
  labels:
    app.kubernetes.io/name: dcgm-exporter
    app.kubernetes.io/instance: nvidia-exporter
spec:
  type: ClusterIP
  ports:
  - name: "metrics"
    port: ${exporter_port}
    targetPort: ${exporter_port}
    protocol: TCP
  selector:
    app.kubernetes.io/name: dcgm-exporter
    app.kubernetes.io/instance: nvidia-exporter
---
apiVersion: apps/v1
kind: DaemonSet
metadata:
  name: nvidia-exporter
  labels:
    app.kubernetes.io/name: dcgm-exporter
    app.kubernetes.io/instance: nvidia-exporter
spec:
  updateStrategy:
    type: RollingUpdate
  selector:
    matchLabels:
      app.kubernetes.io/name: dcgm-exporter
      app.kubernetes.io/instance: nvidia-exporter
spec:
  updateStrategy:
    type: RollingUpdate
  selector:
    matchLabels:
      app.kubernetes.io/name: dcgm-exporter
      app.kubernetes.io/instance: nvidia-exporter
  template:
    metadata:
      labels:
        app.kubernetes.io/name: dcgm-exporter
        app.kubernetes.io/instance: nvidia-exporter
    spec:
      serviceAccountName: nvidia-exporter
      affinity:
        nodeAffinity:
          requiredDuringSchedulingIgnoredDuringExecution:
            nodeSelectorTerms:
            - matchExpressions:
              - key: cloud.google.com/gke-accelerator
                operator: Exists
      tolerations:
      - operator: Exists
      volumes:
      - name: "pod-gpu-resources"
        hostPath:
          path: "/var/lib/kubelet/pod-resources"
      - name: "nvidia-host-binaries"
        hostPath:
          path: "/home/kubernetes/bin/nvidia"
      - name: "dev"
        hostPath:
          path: "/dev"
      containers:
      - name: exporter
        securityContext:
          privileged: true
          runAsNonRoot: false
          runAsUser: 0
        image: "${exporter_image}:${exporter_tag}"
        imagePullPolicy: "IfNotPresent"
        env:
        - name: "DCGM_EXPORTER_KUBERNETES"
          value: "true"
        - name: "DCGM_EXPORTER_LISTEN"
          value: "${exporter_port}"
        - name: LD_LIBRARY_PATH
          value: /usr/local/nvidia/lib64
        ports:
        - name: metrics
          containerPort: ${exporter_port}
        volumeMounts:
        - name: pod-gpu-resources
          readOnly: true
          mountPath: /var/lib/kubelet/pod-resources
        - mountPath: /usr/local/nvidia
          name: nvidia-host-binaries
        - mountPath: /dev
          name: dev
          readOnly: true
        livenessProbe:
          httpGet:
            path: /health
            port: metrics
          initialDelaySeconds: 5
          periodSeconds: 5
        readinessProbe:
          httpGet:
            path: /health
            port: metrics
          initialDelaySeconds: 5
        resources:
          limits:
            cpu: 100m
            memory: 128Mi
          requests:
            cpu: 100m
            memory: 128Mi
---
apiVersion: monitoring.coreos.com/v1
kind: ServiceMonitor
metadata:
  name: nvidia-exporter
  labels:
    app.kubernetes.io/name: dcgm-exporter
    app.kubernetes.io/instance: nvidia-exporter
    monitoring: prometheus
spec:
  selector:
    matchLabels:
      app.kubernetes.io/name: dcgm-exporter
      app.kubernetes.io/instance: nvidia-exporter
  endpoints:
  - port: "metrics"
    path: "/metrics"
  namespaceSelector:
    matchNames:
    - "${namespace}"
  endpoints:
  - port: "metrics"
    path: "/metrics"
    interval: "15s"
