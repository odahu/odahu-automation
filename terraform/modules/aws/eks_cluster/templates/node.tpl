#!/bin/bash
set -o xtrace
/etc/eks/bootstrap.sh --apiserver-endpoint "${endpoint}" --b64-cluster-ca "${certificate_authority}" --kubelet-extra-args '%{if taints != "" } --register-with-taints ${taints}%{ endif } %{ if labels != "" }--node-labels ${labels}%{ endif }'  "${name}"
