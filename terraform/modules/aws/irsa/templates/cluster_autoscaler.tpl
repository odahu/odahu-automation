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
  logtostderr: true
  stderrthreshold: info
  v: 4
  skip-nodes-with-system-pods: false
  skip-nodes-with-local-storage: false
  balance-similar-node-groups: true
  cores-total: 2:${cpu_max_limit}
  memory-total: 8:${mem_max_limit}

podAnnotations:
  iam.amazonaws.com/role: ${iam_role_arn}
