#!/usr/bin/env bash
#Script for Odahuflow clusters orchestration

set -e

function ReadArguments() {
	export VERBOSE=false
	OUTPUT_FILE="$(pwd)/output.json"
	export OUTPUT_FILE
	export TF_SUPPORTED_COMMANDS=(create destroy suspend resume)

	if [[ $# == 0 ]]; then
		echo -e "ERROR:\tOptions aren't specified! Use -h for help!"
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
				echo -e "ERROR:\tUnknown option: $1. Use -h for help."
				exit 1
				;;
		esac
	done

	# Check mandatory parameters
	if [[ ! $COMMAND ]]; then
		echo -e "ERROR:\tCommand argument must be specified. Use -h for help!"
		exit 1
	fi
	# Validate profile path
	if [[ ! $PROFILE ]]; then
		echo -e "ERROR:\tNo PROFILE found. Pass path to the Cluster profile json file as PROFILE env var!"
		exit 1
	fi
	# Validate Command parameter
	if [[ ! "${TF_SUPPORTED_COMMANDS[*]}" =~ ${COMMAND} ]]; then
		echo -e "ERROR:\tIncorrect Command parameter \"$COMMAND\", must be one of: ${TF_SUPPORTED_COMMANDS[*]}!"
		exit 1
	fi
	if [[ $VERBOSE == true ]]; then
		set -x
	fi
}

# Get parameter from cluster profile
function GetParam() {
    if [[ $# -ge 2 ]]; then
        local jsonfile=$2
    else
        local jsonfile=${PROFILE}
    fi
	jq -rc ".$1" "${jsonfile}"
}

function TerragruntRun() {
	TF_MODULE=$1
	TF_COMMAND=$2
	WORK_DIR=$MODULES_ROOT/$TF_MODULE

	cd "${WORK_DIR}"

	TF_DATA_DIR="/tmp/.terraform/$(GetParam 'cluster_name')/$TF_MODULE"
	export TF_DATA_DIR

	echo -e "INFO :\tExecute $TF_COMMAND on $TF_MODULE state"
	case ${TF_COMMAND} in
		"output")
			terragrunt "${TF_COMMAND}" -no-color -json > "${OUTPUT_FILE}"
			;;
		*)
			terragrunt "${TF_COMMAND}" -auto-approve "-var-file=${PROFILE}"
			;;
	esac
}

function SetupCloudAccess() {
	echo -e "INFO :\tActivating service account"
	if [[ $VERBOSE == true ]]; then set +x; fi
	case $(GetParam 'cloud.type') in
		"aws")
			if [[ \
				$(GetParam 'cloud.aws.credentials.AWS_ACCESS_KEY_ID') != "null" && \
				$(GetParam 'cloud.aws.credentials.AWS_SECRET_ACCESS_KEY') != "null" \
			]]; then
				echo -e "INFO :\tUsing AWS cloud credentials from cluster profile"
				AWS_ACCESS_KEY_ID=$(GetParam 'cloud.aws.credentials.AWS_ACCESS_KEY_ID')
				AWS_SECRET_ACCESS_KEY=$(GetParam 'cloud.aws.credentials.AWS_SECRET_ACCESS_KEY')
				export AWS_ACCESS_KEY_ID AWS_SECRET_ACCESS_KEY
			else
				echo -e "INFO :\tUsing AWS cloud credentials from env vars"
				if [[ -z $AWS_ACCESS_KEY_ID || -z $AWS_SECRET_ACCESS_KEY ]]; then
					echo -e "ERROR:\tNo AWS cloud credentials provided!"
					echo -e "\tDeclare AWS_ACCESS_KEY_ID, AWS_SECRET_ACCESS_KEY as environment variables"
					echo -e "\tor define them in the JSON cluster profile"
					exit 1
				fi
			fi
			;;
		"azure")
			if [[ \
				$(GetParam 'cloud.azure.credentials.ARM_CLIENT_ID') != "null" && \
				$(GetParam 'cloud.azure.credentials.ARM_CLIENT_SECRET') != "null" && \
				$(GetParam 'cloud.azure.credentials.ARM_TENANT_ID') != "null" && \
				$(GetParam 'cloud.azure.credentials.ARM_SUBSCRIPTION_ID') != "null" \
			]]; then
				echo -e "INFO :\tUsing Azure cloud credentials from cluster profile"
				ARM_CLIENT_ID=$(GetParam 'cloud.azure.credentials.ARM_CLIENT_ID')
				ARM_CLIENT_SECRET=$(GetParam 'cloud.azure.credentials.ARM_CLIENT_SECRET')
				ARM_TENANT_ID=$(GetParam 'cloud.azure.credentials.ARM_TENANT_ID')
				ARM_SUBSCRIPTION_ID=$(GetParam 'cloud.azure.credentials.ARM_SUBSCRIPTION_ID')
				export ARM_CLIENT_ID ARM_CLIENT_SECRET ARM_TENANT_ID ARM_SUBSCRIPTION_ID
			else
				echo -e "INFO :\tUsing Azure cloud credentials from env vars"
				if [[ -z $ARM_CLIENT_ID || -z $ARM_CLIENT_SECRET || -z $ARM_TENANT_ID || -z $ARM_SUBSCRIPTION_ID ]]; then
					echo -e "ERROR:\tNo Azure cloud credentials provided!"
					echo -e "\tDeclare ARM_CLIENT_ID, ARM_CLIENT_SECRET, ARM_TENANT_ID, ARM_SUBSCRIPTION_ID as environment variables"
					echo -e "\tor define them in the JSON cluster profile"
					exit 1
				fi
			fi
			az login --service-principal -u "${ARM_CLIENT_ID}" -p "${ARM_CLIENT_SECRET}" --tenant "${ARM_TENANT_ID}"
			;;
		"gcp")
			local creds_gcp
			creds_gcp=$(GetParam 'cloud.gcp.credentials.GOOGLE_CREDENTIALS')
			if [[ "${creds_gcp}" != "null" ]]; then
				echo -e "INFO :\tUsing GCP cloud credentials from cluster profile"
				GOOGLE_CREDENTIALS="${creds_gcp}"
				export GOOGLE_CREDENTIALS
			fi

			if [[ -n $GOOGLE_CREDENTIALS ]]; then
				echo -e "INFO :\tUsing GCP cloud credentials from GOOGLE_CREDENTIALS env var"
				if [[ -f $GOOGLE_CREDENTIALS ]]; then
					gcloud auth activate-service-account \
						"--key-file=${GOOGLE_CREDENTIALS}" \
						"--project=$(GetParam 'cloud.gcp.project_id')"
				else
					gcloud auth activate-service-account \
						"--key-file=/dev/fd/3" \
						"--project=$(GetParam 'cloud.gcp.project_id')" \
						3<<<"${GOOGLE_CREDENTIALS}"
				fi
			else
				echo -e "ERROR:\tGCP cloud credentials are not defined not as GOOGLE_CREDENTIALS env var"
				echo -e "\tnor as credentials string in JSON profile 'cloud' section."
				echo -e "\tTrying to proceed with GCP instance metadata service account..."
			fi
			;;
		*)
			echo -e "ERROR:\t'cloud_type' is not defined or has wrong value"
			exit 1
			;;
	esac
	if [[ $VERBOSE == true ]]; then set -x; fi
}

# Create Odahuflow cluster
function TerraformCreate() {
	case $(GetParam "cluster_type") in
		"aws/eks")
			TerragruntRun eks_create apply
			;;
		"gcp/gke")
			TerragruntRun gke_create apply
			;;
		"azure/aks")
			TerragruntRun aks_create apply
			;;
	esac
	TerragruntRun helm_init apply
	TerragruntRun k8s_setup apply
	echo 'INFO : Create Odahuflow DNS records'
	TerragruntRun k8s_setup output
	case $(GetParam "cluster_type") in
		"aws/eks")
			LB_IP="$(GetParam 'load_balancer_ip.value' "$OUTPUT_FILE")."
			;;
		"gcp/gke")
			LB_IP=$(GetParam 'helm_values.value["controller.service.loadBalancerIP"]' "$OUTPUT_FILE")
			;;
		"azure/aks")
			LB_IP=$(GetParam 'helm_values.value["controller.service.loadBalancerIP"]' "$OUTPUT_FILE")
			;;
	esac
	CLUSTER_FQDN="$(GetParam 'dns.domain')"
        # shellcheck disable=SC2001
	DOMAIN="$(sed 's/^[0-9a-zA-Z-]*.//' <<< "$CLUSTER_FQDN")"
        CLUSTER_SUBDOMAIN="${CLUSTER_FQDN//.${DOMAIN}//}"
	case $(GetParam "cluster_type") in
		"aws/eks")
			TerragruntRun eks_create output
			K8S_API_IP="$(GetParam 'k8s_api_address.value' "$OUTPUT_FILE" | sed -e 's/https:\/\///')."
			BASTION_IP=$(GetParam 'bastion_address.value' "$OUTPUT_FILE")
			TF_VAR_records=$(jq -rn "[{name: \"bastion.$CLUSTER_SUBDOMAIN\", value: \"$BASTION_IP\"}, {name: \"$CLUSTER_SUBDOMAIN\", value: \"$LB_IP\", type: \"CNAME\"}, {name: \"api.$CLUSTER_SUBDOMAIN\", value: \"$K8S_API_IP\", type: \"CNAME\"}]")
			;;
		"gcp/gke")
			TerragruntRun gke_create output
			K8S_API_IP=$(GetParam 'k8s_api_address.value' "$OUTPUT_FILE")
			BASTION_IP=$(GetParam 'bastion_address.value' "$OUTPUT_FILE")
			TF_VAR_records=$(jq -rn "[{name: \"bastion.$CLUSTER_SUBDOMAIN\", value: \"$BASTION_IP\"}, {name: \"$CLUSTER_SUBDOMAIN\", value: \"$LB_IP\"}, {name: \"api.$CLUSTER_SUBDOMAIN\", value: \"$K8S_API_IP\"}]")
			;;
		"azure/aks")
			TerragruntRun aks_create output
			K8S_API_IP="$(GetParam 'k8s_api_address.value' "$OUTPUT_FILE" | sed -e 's/^https:\/\///'| sed -e 's/:443//')."
			BASTION_IP=$(GetParam 'bastion_address.value' "$OUTPUT_FILE")
			TF_VAR_records=$(jq -rn "[{name: \"bastion.$CLUSTER_SUBDOMAIN\", value: \"$BASTION_IP\"}, {name: \"$CLUSTER_SUBDOMAIN\", value: \"$K8S_API_IP\", type: \"CNAME\"}]")
			;;
	esac
	export TF_VAR_records

	TerragruntRun odahu_dns apply
	TerragruntRun odahuflow apply
	echo "INFO : Save cluster info to ${OUTPUT_FILE}"
	TerragruntRun odahuflow output
}

# Destroy Odahuflow cluster
function TerraformDestroy() {
	if CheckCluster; then
		TerragruntRun odahuflow destroy

		export TF_VAR_records='[]'
		TerragruntRun odahu_dns destroy

		TerragruntRun k8s_setup destroy
		TerragruntRun helm_init destroy
	else
		echo -e "ERROR:\tThere is no cluster found with name \"$(GetParam 'cluster_name')\""
	fi
	case $(GetParam 'cluster_type') in
		"aws/eks")
			TerragruntRun eks_create destroy
			;;
		"gcp/gke")
			TerragruntRun gke_create destroy
			;;
		"azure/aks")
			TerragruntRun aks_create destroy
			;;
	esac
}

# Check that k8s cluster exists
function CheckCluster() {
	case $(GetParam 'cluster_type') in
		"aws/eks")
			if aws eks list-clusters \
				--region "$(GetParam 'cloud.aws.region')" | grep "$(GetParam 'cluster_name')"; then
				true
			else
				false
			fi
			;;
		"gcp/gke")
			if gcloud container clusters list \
				--zone "$(GetParam 'cloud.gcp.region')" | grep -E "^$(GetParam 'cluster_name') .*"; then
				true
			else
				false
			fi
			;;
		"azure/aks")
			if az aks list \
				--resource-group "$(GetParam 'cloud.azure.resource_group')" \
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
	echo -e 'INFO :\tAuthorize Kubernetes API access'
	case $(GetParam "cluster_type") in
		"gcp/gke")
			gcloud container clusters get-credentials "$(GetParam 'cluster_name')" \
				--zone "$(GetParam 'cloud.gcp.region')" --project "$(GetParam 'cloud.gcp.project_id')"
			;;
	esac
}

function SuspendCluster() {
	local cluster_type
	local cluster_name

	[[ $(GetParam "cluster_type") != "null" ]] && cluster_type=$(GetParam "cluster_type") || exit 1
	[[ $(GetParam "cluster_name") != "null" ]] && cluster_name=$(GetParam "cluster_name") || exit 1

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
						--min-nodes 0 --max-nodes "$(GetParam 'node_pools.main.max_node_count')" \
						--node-locations "$(GetParam 'cloud.gcp.node_locations | join(",")')" \
						--region "$(GetParam 'cloud.gcp.region')" \
						--quiet

					# Here we limit the maximum node pool count to existing nodes count (divided by locations count)
					gcloud beta container clusters update "${cluster_name}" \
						--region "$(GetParam 'cloud.gcp.region')" \
						--node-pool "main" \
						--enable-autoscaling \
						--max-nodes $(( "$(echo "${k_nodes}" | wc -w)" / $(GetParam 'cloud.gcp.node_locations | length') )) \
						--quiet

					kubectl get pods --no-headers=true --all-namespaces | \
						sed -r 's/(\S+)\s+(\S+).*/kubectl --namespace \1 delete pod --grace-period=0 --force \2 2>\/dev\/null/e'

					gcloud beta container clusters resize "${cluster_name}" \
						--region "$(GetParam 'cloud.gcp.region')" \
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

	[[ $(GetParam "cluster_type") != "null" ]] && cluster_type=$(GetParam "cluster_type") || exit 1
	[[ $(GetParam "cluster_name") != "null" ]] && cluster_name=$(GetParam "cluster_name") || exit 1

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
						--region "$(GetParam 'cloud.gcp.region')" \
						--node-pool "main" \
						--num-nodes "$(GetParam 'node_pools.main.init_node_count')" \
						--quiet

					until [[ -z "$(kubectl get pods --no-headers=true --all-namespaces --field-selector=status.phase==Pending 2>/dev/null)" ]]; do
						sleep 5
					done

					gcloud beta container clusters update "${cluster_name}" \
						--region "$(GetParam 'cloud.gcp.region')" \
						--node-pool "main" \
						--enable-autoscaling \
						--min-nodes "$(GetParam 'node_pools.main.min_node_count')" \
						--max-nodes "$(GetParam 'node_pools.main.max_node_count')" \
						--quiet

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
SetupCloudAccess

export TF_IN_AUTOMATION=true
export TF_PLUGIN_CACHE_DIR=/tmp/.terraform/cache && mkdir -p $TF_PLUGIN_CACHE_DIR
MODULES_ROOT="/opt/odahu-flow/terraform/env_types/$(GetParam 'cluster_type')"
export MODULES_ROOT

if [[ $COMMAND == 'create' ]]; then
	TerraformCreate
elif [[ $COMMAND == 'destroy' ]]; then
	TerraformDestroy
elif [[ $COMMAND == 'suspend' ]]; then
	SuspendCluster
elif [[ $COMMAND == 'resume' ]]; then
	ResumeCluster
fi
