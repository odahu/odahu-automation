cloudProvider: aws
awsRegion: ${region}

image:
  tag: ${version}

autoDiscovery:
  clusterName: ${cluster_name}
  tags:
  - k8s.io/cluster-autoscaler/enabled
  - k8s.io/cluster-autoscaler/${cluster_name}

extraArgs:
  cluster-name: ${cluster_name}
  logtostderr: true
  stderrthreshold: info
  v: 4
  skip-nodes-with-system-pods: false
  skip-nodes-with-local-storage: false
  balance-similar-node-groups: true
  cores-total: 2:${cpu_max_limit}
  memory-total: 8:${mem_max_limit}

rbac:
  create: true
  pspEnabled: true
  serviceAccount:
    annotations:
      eks.amazonaws.com/role-arn: ${iam_role_arn}
    create: true
    name:
      cluster-autoscaler

