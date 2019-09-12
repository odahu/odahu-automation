#!/usr/bin/env bash
#Script for Legion clusters orchestration

set -ex
function ReadArguments() {

	export VERBOSE=false
	export TF_SUPPORTED_COMMANDS=(create destroy)

	if [ $# == 0 ]; then
		echo "Options not specified! Use -h for help!"
		exit 1
	fi

	while test $# -gt 0
	do
        case "$1" in
            -h|--help)
				echo "tf_runner.sh - Run Terraform modules for Legion clusters orchestration."
				echo "Usage: ./tf_runner.sh [OPTIONS]"
				echo " "
				echo "options:"
                echo "command[create|destroy]         command to execute: ${TF_SUPPORTED_COMMANDS[@]}"
				echo "-t  --verbose          		  verbose mode for debug purposes"
                echo "-h  --help               		  show brief help"
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
			*)
				echo "Unknown option: $1. Use -h for help."
				exit 1
				;;
		esac
	done

	# Check mandatory parameters
	if [ ! $COMMAND ]; then
		echo "Error! --command argument must be specified. Use -h for help!"
		exit 1
	fi
	# Read GCP credentials path from env
	if [ ! $GOOGLE_CREDENTIALS ]; then
		echo "Error: No GCP credentials found. Pass path to the credentials json file as GOOGLE_CREDENTIALS env var!"
		exit 1
	fi
	if [ ! $PROFILE ]; then
		echo "Error: No PROFILE found. Pass path to the Cluster profile json file as PROFILE env var!"
		exit 1
	fi
	# Validate profile path
	if [ ! -f $GOOGLE_CREDENTIALS ]; then
		echo "Error: no Cluster profile found at $GOOGLE_CREDENTIALS path!"
		exit 1
	fi
	# Validate Command parameter
	if [[ ! " ${TF_SUPPORTED_COMMANDS[@]} " =~ " ${COMMAND} " ]]; then
		echo "Error: incorrect Command parameter \"$COMMAND\", must be one of ${TF_SUPPORTED_COMMANDS[@]}!"
		exit 1
	fi
}

# Get parameter from cluster profile
function GetParam() {
	result=$(jq ".$1" $PROFILE | tr -d '"')
	if [ ! $result ]; then
		echo "Error: $1 parameter missed in $PROFILE cluster profile"
		exit 1
	else
		echo $result
	fi
}

function TerraformRun() {
	MODULES_ROOT=/opt/legion/terraform/env_types/gcp/gke/
	TF_MODULE=$1
	TF_COMMAND=$2
	WORK_DIR=$MODULES_ROOT/$TF_MODULE

	cd $WORK_DIR
	export TF_DATA_DIR=/tmp/.terraform-$(GetParam 'cluster_name')-$TF_MODULE
	terraform init -no-color -backend-config="bucket=$(GetParam 'tfstate_bucket')"
	
	echo "Execute $TF_COMMAND on $TF_MODULE state"
	terraform $TF_COMMAND -no-color -auto-approve -var-file=$PROFILE
}

function SetupGCPAccess() {
	echo "Activate service account"
    gcloud auth activate-service-account --key-file=$GOOGLE_CREDENTIALS --project=$(GetParam "project_id")
}

# Create Legion cluster
function TerraformCreate() {
	echo 'INFO: Apply gke_create TF module'
	TerraformRun gke_create apply
	echo 'INFO: Authorize Kubernetes API access'
	gcloud container clusters get-credentials $(GetParam "cluster_name") --zone $(GetParam "location") --project=$(GetParam "project_id")
	echo 'INFO: Init HELM'
	TerraformRun helm_init apply
	echo 'INFO: Setup K8S Legion dependencies'
	TerraformRun k8s_setup apply
	echo 'INFO: Deploy Legion components'
	TerraformRun legion apply
}

# Destroy Legion cluster
function TerraformDestroy() {

	if gcloud container clusters list --zone $(GetParam "location") | grep $(GetParam "cluster_name") ; then

		echo 'INFO: Authorize Kubernetes API access'
		gcloud container clusters get-credentials $(GetParam "cluster_name") --zone $(GetParam "location") --project=$(GetParam "project_id")

		echo 'INFO: Init HELM'
		helm init --client-only

		echo 'INFO: Destroy Legion components'
		TerraformRun legion destroy
		echo 'INFO: Destroy K8S Legion dependencies'
		TerraformRun k8s_setup destroy
		echo 'INFO: Destroy Helm'
		TerraformRun helm_init destroy
		echo "INFO: Remove auto-generated fw rules"
		fw_filter="name:k8s- AND network:$(GetParam "cluster_name")-vpc"

		for i in $(gcloud compute firewall-rules list --filter="${fw_filter}" --format='value(name)' --project=$(GetParam "project_id")); do
			gcloud compute firewall-rules delete $i --quiet
		done

		echo 'INFO: Destroy GKE cluster'
		TerraformRun gke_create destroy
	else
		echo "INFO: no $(GetParam "cluster_name") available"
	fi
}


##################
### Do the job 
##################

ReadArguments "$@"
SetupGCPAccess

if [ $COMMAND == 'create' ]; then
	TerraformCreate
elif [ $COMMAND == 'destroy' ]; then
	TerraformDestroy
else
	echo "Error: invalid command!"
	exit 1
fi
