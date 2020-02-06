#!/usr/bin/env bash
#Script for Odahuflow clusters orchestration

set -e

function ReadArguments() {
	export VERBOSE=false
	export OUTPUT_FILE="output.json"
	export TF_SUPPORTED_COMMANDS=(create destroy suspend resume)

	if [[ $# == 0 ]]; then
		echo "ERROR: Options not specified! Use -h for help!"
		exit 1
	fi

	while [[ $# -gt 0 ]]; do
		case "$1" in
			-h|--help)
				echo "tf_runner.sh - Run Terraform modules for Odahuflow clusters orchestration."
				echo -e "Usage: ./tf_runner.sh [OPTIONS]\n\noptions:"
				echo "command to execute: \"${TF_SUPPORTED_COMMANDS[*]}\""
				echo -e "-v  --verbose\t\tverbose mode for debug purposes"
				echo -e "-o  --output\t\toutput file name"
				echo -e "-h  --help\t\tshow brief help"
				exit 0
				;;
			create)
				export COMMAND="create"
				shift
				;;
			destroy)
				shift
				export COMMAND="destroy"
				;;
			suspend)
				shift
				export COMMAND="suspend"
				;;
			resume)
				shift
				export COMMAND="resume"
				;;
			-v|--verbose)
				export VERBOSE=true
				shift
				;;
			-o|--output)
				export OUTPUT_FILE=$2
				shift 2
				;;
			*)
				echo "ERROR: Unknown option: $1. Use -h for help."
				exit 1
				;;
		esac
	done

	# Check mandatory parameters
	if [[ ! $COMMAND ]]; then
		echo "ERROR: Command argument must be specified. Use -h for help!"
		exit 1
	fi
	# Validate profile path
	if [[ ! $PROFILE ]]; then
		echo "ERROR: No PROFILE found. Pass path to the Cluster profile json file as PROFILE env var!"
		exit 1
	fi
	# Validate Command parameter
	if [[ ! "${TF_SUPPORTED_COMMANDS[*]}" =~ ${COMMAND} ]]; then
		echo "ERROR: incorrect Command parameter \"$COMMAND\", must be one of: ${TF_SUPPORTED_COMMANDS[*]}!"
		exit 1
	fi
	if [[ $VERBOSE == true ]]; then
		set -x
	fi
}

# Get parameter from specified JSON file
function GetParam() {
    if [[ $# -ge 2 ]]; then
        local jsonfile=$2
    else
        local jsonfile=${PROFILE}
    fi

    result=$(jq -rc ".$1" "${jsonfile}")
    if [[ "$result" == null ]]; then
        echo "ERROR: $1 parameter is missing in ${jsonfile}"
        exit 1
    else
        echo "$result"
    fi
}

function TerraformRun() {
	TF_MODULE=$1
	TF_COMMAND=$2
	WORK_DIR=$MODULES_ROOT/$TF_MODULE

	local TF_COMMON_ARGS="-no-color -compact-warnings"

	cd "${WORK_DIR}"

	TF_DATA_DIR="/tmp/.terraform/$(GetParam 'cluster_name')/$TF_MODULE"
	export TF_DATA_DIR

	case $(GetParam "cluster_type") in
		"aws/eks")
			terraform init $TF_COMMON_ARGS \
				-backend-config="bucket=$(GetParam 'tfstate_bucket')" \
				-backend-config="region=$(GetParam 'aws_region')"
			;;
		"gcp/gke")
			terraform init $TF_COMMON_ARGS \
				-backend-config="bucket=$(GetParam 'tfstate_bucket')" \
				-backend-config="prefix=$TF_MODULE"
			;;
		"azure/aks")
			terraform init $TF_COMMON_ARGS \
				-backend-config="container_name=$(GetParam 'tfstate_bucket')" \
				-backend-config="resource_group_name=$(GetParam 'azure_resource_group')" \
				-backend-config="storage_account_name=$(GetParam 'azure_storage_account')" \
				-backend-config="key=$TF_MODULE/default.tfstate"
			;;
	esac

	echo "INFO : Execute $TF_COMMAND on $TF_MODULE state"
	case ${TF_COMMAND} in
		"output")
			terraform "${TF_COMMAND}" -json -no-color > ${OUTPUT_FILE}
			;;
		*)
			terraform "${TF_COMMAND}" $TF_COMMON_ARGS -auto-approve "-var-file=${PROFILE}"
			;;
	esac
}

function TerragruntRun() {
	TF_MODULE=$1
	TF_COMMAND=$2
	WORK_DIR=$MODULES_ROOT/$TF_MODULE

	cd "${WORK_DIR}"

	TF_DATA_DIR="/tmp/.terraform/$(GetParam 'cluster_name')/$TF_MODULE"
	export TF_DATA_DIR

	terragrunt init -no-color
	echo "INFO : Execute $TF_COMMAND on $TF_MODULE state"
	terragrunt apply -no-color -auto-approve
}

function CloudGetCredentials() {
	echo "INFO : Getting access to the cloud"
	local env_creds_defined=false
	if [[ $VERBOSE == true ]]; then set +x; fi
	case $(GetParam 'cloud_type') in
		"aws")
			if [[ -n $AWS_ACCESS_KEY_ID && -n $AWS_SECRET_ACCESS_KEY ]]; then
				env_creds_defined=true
			fi
			;;
		"gcp")
			if [[ -n $GOOGLE_CREDENTIALS || -f $GOOGLE_CREDENTIALS ]]; then
				env_creds_defined=true
				local gcp_project_id
				gcp_project_id=$(GetParam "project_id" $GOOGLE_CREDENTIALS) || exit 1
				export GOOGLE_PROJECT_ID=${gcp_project_id}
			fi
			;;
		"azure")
			if [[ -n $ARM_CLIENT_ID && -n $ARM_CLIENT_SECRET && -n $ARM_TENANT_ID && -n $ARM_SUBSCRIPTION_ID ]]; then
				env_creds_defined=true
			fi
			;;
		*)
			echo "ERROR: 'cloud_type' is not defined or has wrong value"
			exit 1
			;;
	esac

	if $env_creds_defined; then
		echo "INFO : Credentials vars are defined in environment, we'll not parse the profile"
	else
		local CloudCreds
		CloudCreds=$(GetParam "cloud_credentials.$(GetParam "cloud_type")") || (echo "ERROR: \"cloud_credentials.$(GetParam \"cloud_type\")\" parameter is missing in profile" && exit 1)
		case $(GetParam 'cloud_type') in
			"aws")
				;;
			"azure")
				;;
			"gcp")
				export GOOGLE_CREDENTIALS=${CloudCreds}
				local gcp_project_id
				gcp_project_id=$(GetParam "cloud_credentials.$(GetParam "cloud_type").project_id") || exit 1
				export GOOGLE_PROJECT_ID=${gcp_project_id}
				;;
			*)
				echo "ERROR: 'cloud_type' is not defined or has wrong value"
				exit 1
				;;
		esac
	fi

	if [[ $VERBOSE == true ]]; then set -x; fi
}

function CloudAuth() {
	echo 'INFO : Activating cloud service account'
	if [[ $VERBOSE == true ]]; then set +x; fi
	case $(GetParam "cloud_type") in
		"aws")
			;;
		"gcp")
			if [[ -f ${GOOGLE_CREDENTIALS} ]]; then
				gcloud auth activate-service-account --key-file=${GOOGLE_CREDENTIALS} --project=${GOOGLE_PROJECT_ID}
			else
				echo ${GOOGLE_CREDENTIALS} | gcloud auth activate-service-account --key-file=/dev/stdin --project=${GOOGLE_PROJECT_ID}
			fi
			;;
		"azure")
			az login --service-principal -u "${ARM_CLIENT_ID}" -p "${ARM_CLIENT_SECRET}" --tenant "${ARM_TENANT_ID}"
			;;
	esac
	if [[ $VERBOSE == true ]]; then set -x; fi
}

# Create Odahuflow cluster
function CreateCluster() {
	echo 'INFO : Applying k8s create TF module'
	jq -n env && sleep 5
	case $(GetParam "cluster_type") in
		"aws/eks")
			TerraformRun eks_create apply
			;;
		"gcp/gke")
			TerraformRun gke_create apply
			;;
		"azure/aks")
			TerraformRun aks_create apply
			;;
	esac
	FetchKubeConfig
	echo 'INFO : Init HELM'
	TerraformRun helm_init apply
	echo 'INFO : Setup K8S Odahuflow dependencies'
	TerraformRun k8s_setup apply

	GetDNSData
	TerragruntRun odahu_dns apply

	echo 'INFO : Deploy ODAHU components'
	TerraformRun odahuflow apply
	echo "INFO : Save cluster info to ${OUTPUT_FILE}"
	TerraformOutput odahuflow
}

function TerraformOutput() {
	TF_MODULE=$1
	echo 'INFO : Return cluster data in JSON'
	TerraformRun $TF_MODULE output
}

function GetDNSData() {
	echo 'INFO : Create ODAHU DNS records'
	TerraformOutput k8s_setup
	case $(GetParam "cluster_type") in
		"aws/eks")
			TerraformOutput eks_create
			LB_IP="$(jq -rc '.load_balancer_ip.value' $MODULES_ROOT/k8s_setup/$OUTPUT_FILE)."
			K8S_API_IP="$(jq -rc '.k8s_api_address.value' $MODULES_ROOT/eks_create/$OUTPUT_FILE | sed -e 's/https:\/\///')."
			BASTION_IP=$(jq -rc '.bastion_address.value' $MODULES_ROOT/eks_create/$OUTPUT_FILE)
			export TF_VAR_records=$(jq -rn "[{name: \"bastion.$(GetParam 'cluster_name')\", value: \"$BASTION_IP\"}, {name: \"odahu.$(GetParam 'cluster_name')\", value: \"$LB_IP\", type: \"CNAME\"}, {name: \"api.$(GetParam 'cluster_name')\", value: \"$K8S_API_IP\", type: \"CNAME\"}]")
			;;
		"gcp/gke")
			TerraformOutput gke_create
			LB_IP=$(jq -rc '.helm_values.value["controller.service.loadBalancerIP"]' $MODULES_ROOT/k8s_setup/$OUTPUT_FILE)
			K8S_API_IP=$(jq -rc '.k8s_api_address.value' $MODULES_ROOT/gke_create/$OUTPUT_FILE)
			BASTION_IP=$(jq -rc '.bastion_address.value' $MODULES_ROOT/gke_create/$OUTPUT_FILE)
			export TF_VAR_records=$(jq -rn "[{name: \"bastion.$(GetParam 'cluster_name')\", value: \"$BASTION_IP\"}, {name: \"odahu.$(GetParam 'cluster_name')\", value: \"$LB_IP\"}, {name: \"api.$(GetParam 'cluster_name')\", value: \"$K8S_API_IP\"}]")
			;;
		"azure/aks")
			TerraformOutput aks_create
			LB_IP=$(jq -rc '.helm_values.value["controller.service.loadBalancerIP"]' $MODULES_ROOT/k8s_setup/$OUTPUT_FILE)
			K8S_API_IP="$(jq -rc '.k8s_api_address.value' $MODULES_ROOT/aks_create/$OUTPUT_FILE | sed -e 's/^https:\/\///'| sed -e 's/:443//')."
			BASTION_IP=$(jq -rc '.bastion_address.value' $MODULES_ROOT/aks_create/$OUTPUT_FILE)
			export TF_VAR_records=$(jq -rn "[{name: \"bastion.$(GetParam 'cluster_name')\", value: \"$BASTION_IP\"}, {name: \"odahu.$(GetParam 'cluster_name')\", value: \"$LB_IP\"}, {name: \"api.$(GetParam 'cluster_name')\", value: \"$K8S_API_IP\", type: \"CNAME\"}]")
			;;
	esac
}

function FlushGKEFirewallRules() {
	echo 'INFO : Remove auto-generated GKE firewall rules'
	if [[ $(GetParam 'network_name') == null ]]; then
		fw_network="$(GetParam 'cluster_name')-vpc"
	else
		fw_network="$(GetParam 'network_name')"
	fi
	fw_filter="name:k8s- AND network:${fw_network}"
	for i in $(gcloud compute firewall-rules list --filter="${fw_filter}" --format='value(name)' --project="${GOOGLE_PROJECT_ID}"); do
		gcloud compute firewall-rules delete "${i}" --quiet
	done
}

# Destroy Odahuflow cluster
function DestroyCluster() {
	if CheckCluster; then
		echo 'Destroy DNS records'
		export TF_VAR_records='[]'
		TerragruntRun odahu_dns destroy

		FetchKubeConfig

		echo 'INFO : Init HELM'
		helm init --client-only

		echo 'INFO : Destroy Odahuflow components'
		TerraformRun odahuflow destroy
		echo 'INFO : Destroy K8S Odahuflow dependencies'
		TerraformRun k8s_setup destroy
		echo 'INFO : Destroy Helm'
		TerraformRun helm_init destroy
		rm -rf ~/.kube
	else
		echo "ERROR: There is no cluster found with name \"$(GetParam 'cluster_name')\""
	fi

	case $(GetParam 'cluster_type') in
		"aws/eks")
			echo 'INFO : Destroy EKS cluster'
			TerraformRun eks_create destroy
			;;
		"gcp/gke")
			FlushGKEFirewallRules
			echo 'INFO : Destroy GKE cluster'
			TerraformRun gke_create destroy
			;;
		"azure/aks")
			echo 'INFO : Destroy AKS cluster'
			TerraformRun aks_create destroy
			;;
	esac
}

# Check that k8s cluster exists
function CheckCluster() {
	CloudAuth
	case $(GetParam 'cluster_type') in
		"aws/eks")
			if aws eks list-clusters \
				--region "$(GetParam 'aws_region')" | grep "$(GetParam 'cluster_name')"; then
				true
			else
				false
			fi
			;;
		"gcp/gke")
			if gcloud container clusters list \
				--zone "$(GetParam 'gcp_region')" | grep -E "^$(GetParam 'cluster_name') .*"; then
				true
			else
				false
			fi
			;;
		"azure/aks")
			if az aks list \
				--resource-group "$(GetParam 'azure_resource_group')" \
				--query [].name -o tsv | grep -E "^$(GetParam 'cluster_name')$"; then
				true
			else
				false
			fi
			;;
	esac
}

# Get kubeconfig from deployed cluster
function FetchKubeConfig() {
	echo 'INFO : Authorize Kubernetes API access'
	case $(GetParam "cluster_type") in
		"aws/eks")
			aws eks update-kubeconfig --name "$(GetParam 'cluster_name')" \
				--region "$(GetParam 'aws_region')"
			;;
		"gcp/gke")
			CloudAuth
			gcloud container clusters get-credentials "$(GetParam 'cluster_name')" \
				--zone "$(GetParam 'gcp_region')" \
				--project "${GOOGLE_PROJECT_ID}"
			;;
		"azure/aks")
			CloudAuth
			az aks get-credentials --name "$(GetParam 'cluster_name')" \
				--resource-group "$(GetParam 'azure_resource_group')"
			;;
	esac
}

function SuspendCluster() {
	local cluster_type
	local cluster_name

	cluster_type=$(GetParam "cluster_type") || exit 1
	cluster_name=$(GetParam "cluster_name") || exit 1

	case ${cluster_type} in
		"gcp/gke")
			if CheckCluster; then
				FetchKubeConfig

				local k_nodes
				k_nodes=$(kubectl get nodes --no-headers=true 2>/dev/null | awk '{print $1}')
				if [[ -n "${k_nodes}" ]]; then
					for node in ${k_nodes}; do
						kubectl cordon "$node"
					done

					gcloud beta container clusters update "${cluster_name}" \
						--node-pool "main" \
						--min-nodes 0 --max-nodes $(( $(GetParam 'initial_node_count') / 2 )) \
						--node-locations "$(GetParam 'node_locations | join(",")')" \
						--region "$(GetParam 'gcp_region')" \
						--quiet

					gcloud beta container clusters update "${cluster_name}" \
						--region "$(GetParam 'gcp_region')" \
						--node-pool "main" \
						--enable-autoscaling \
						--max-nodes "$(echo "${k_nodes}" | wc -w)" \
						--quiet

					kubectl get pods --no-headers=true --all-namespaces | \
						sed -r 's/(\S+)\s+(\S+).*/kubectl --namespace \1 delete pod --grace-period=0 --force \2 2>\/dev\/null/e'

					gcloud beta container clusters resize "${cluster_name}" \
						--region "$(GetParam 'gcp_region')" \
						--node-pool "main" \
						--num-nodes 0 \
						--quiet

					gcloud compute instances list --format="csv[no-heading](name,zone)" \
						--filter="labels.cluster_name:${cluster_name} AND name ~ ^bastion" | \
						sed -r 's/(\S+),(\S+).*/gcloud compute instances stop \1 --zone \2/e'
				else
					echo "ERROR: List of cluster nodes is empty - there's nothing to suspend"
					exit 1
				fi
			fi
			;;
		*)
			echo "ERROR: Unknown cluster type \"${cluster_type}\" provided"
			exit 1
			;;
	esac
}

function ResumeCluster() {
	local cluster_type
	local cluster_name

	cluster_type=$(GetParam "cluster_type") || exit 1
	cluster_name=$(GetParam "cluster_name") || exit 1

	case ${cluster_type} in
		"gcp/gke")
			if CheckCluster; then
				FetchKubeConfig

				local k_nodes
				k_nodes=$(kubectl get nodes --no-headers=true 2>/dev/null | awk '{print $1}')
				if [[ -z "${k_nodes}" ]]; then
					gcloud compute instances list --format="csv[no-heading](name,zone)" \
						--filter="labels.cluster_name:${cluster_name} AND name ~ ^bastion" | \
						sed -r 's/(\S+),(\S+).*/gcloud compute instances start \1 --zone \2/e'

					gcloud beta container clusters resize "${cluster_name}" \
						--region "$(GetParam 'gcp_region')" \
						--node-pool "main" \
						--num-nodes $(( $(GetParam 'initial_node_count') / 2 - 1 )) \
						--quiet

					until [[ -z "$(kubectl get pods --no-headers=true --all-namespaces --field-selector=status.phase==Pending 2>/dev/null)" ]]; do
						sleep 5
					done
				else
					echo "ERROR: List of cluster nodes is not empty - it seems that cluster is already resumed"
					exit 1
				fi
			fi
			;;
		*)
			echo "ERROR: Unknown cluster type \"${cluster_type}\" provided"
			exit 1
			;;
	esac
}


##################
### Do the job
##################

ReadArguments "$@"
CloudGetCredentials

export TF_IN_AUTOMATION=true
export TF_PLUGIN_CACHE_DIR=/tmp/.terraform/cache && mkdir -p $TF_PLUGIN_CACHE_DIR
MODULES_ROOT="/opt/odahu-flow/terraform/env_types/$(GetParam 'cluster_type')"
export MODULES_ROOT

if [[ $COMMAND == 'create' ]]; then
	CreateCluster
elif [[ $COMMAND == 'destroy' ]]; then
	DestroyCluster
elif [[ $COMMAND == 'suspend' ]]; then
	SuspendCluster
elif [[ $COMMAND == 'resume' ]]; then
	ResumeCluster
fi
