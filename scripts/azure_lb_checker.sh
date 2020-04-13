#!/usr/bin/env bash

set -e

if [[ $# == 0 ]]; then
  echo -e "ERROR:\tParameters are not specified!"
  echo -e "\tUsage example:"
  echo -e "\t\t$0 apply <ingress-ip>"
  echo -e "\t\t$0 destroy <aks-resource-group-name> <ingress-ip-name>"
  exit 1
fi

if [[ $# -ge 1 ]]; then
  check_cmd="echo ok"
  if [[ "$1" == "apply" ]]; then
    IP_ADDR=$2
    check_cmd="kubectl get \
      --allow-missing-template-keys \
      --ignore-not-found \
      -n kube-system \
      svc/nginx-ingress-controller \
      --template=\"{{range .status.loadBalancer.ingress}}{{.ip}}{{end}}\" \
      | grep -E \"^${IP_ADDR}$\""

    until eval "${check_cmd}"; do
      sleep 3
    done
  elif [[ "$1" == "destroy" ]]; then
    RG_NAME=$2
    IP_NAME=$3
    check_cmd="az network lb list \
      --resource-group \"${RG_NAME}\" \
      -o tsv \
      --query '[].frontendIpConfigurations[?ends_with(publicIpAddress.id, \`${IP_NAME}\`)].publicIpAddress.id'"

    until [[ "$(eval "${check_cmd}" | wc -c)" -le 1 ]]; do
      sleep 3
    done
  fi
fi
