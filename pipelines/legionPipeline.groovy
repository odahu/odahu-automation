def buildDescription(){
   if (env.param_cluster_name) {
        currentBuild.description = "${env.param_cluster_name} ${env.param_git_branch}"
    } else {
        currentBuild.description = "${env.param_profile} ${env.param_git_branch}"
    }
}

def ansibleDebugRunCheck(String debugRun) {
    // Run ansible playbooks and helm charts from sources in workspace and use verbose output for debug purposes
    if (debugRun == "true" ) {
      ansibleHome =  "${WORKSPACE}/ansible"
      ansibleVerbose = '-vvv'
    } else {
      ansibleHome = env.ansibleHome
      ansibleVerbose = env.ansibleVerbose
    }
}

def getWanIp() {
    agentWanIp = sh returnStdout: true, script: "curl -s http://checkip.amazonaws.com/ |tr -d '\n'"
    print("Running on: " + agentWanIp)
    env.agentWanIp = agentWanIp
}

def createCluster() {
    withCredentials([
    file(credentialsId: "vault-${env.param_profile}", variable: 'vault')]) {
        withAWS(credentials: 'kops') {
            wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
                docker.image("${env.param_docker_repo}/k8s-ansible:${env.param_legion_infra_version}").inside("-e HOME=/opt/legion -v ${WORKSPACE}/profiles:/opt/legion/profiles -u root") {
                    stage('Create cluster') {
                        sh """
                        cd ${ansibleHome} && \
                        ansible-playbook create-cluster.yml \
                        ${ansibleVerbose} \
                        --vault-password-file=${vault} \
                        --extra-vars "profile=${env.param_profile} \
                        legion_infra_version=${env.param_legion_infra_version} \
                        skip_kops=${env.param_skip_kops} \
                        helm_repo=${env.param_helm_repo}" 
                        """
                    }
                }
            }
        }
    }
}

def createGCPCluster() {
    withCredentials([
    file(credentialsId: "${env.gcpCredential}", variable: 'gcpCredential')]) {
        withCredentials([
        file(credentialsId: "${env.param_cluster_name}-gcp-secrets", variable: 'secrets')]) {
            withAWS(credentials: 'kops') {
                wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
                    docker.image("${env.param_docker_repo}/k8s-terraform:${env.param_legion_infra_version}").inside("-e GOOGLE_CREDENTIALS=${gcpCredential} -e CLUSTER_NAME=${env.param_cluster_name} -u root") {
                        stage('Create GCP resources') {
                            sh """
                            set -ex
                            # Activate service account
                            gcloud auth activate-service-account --key-file=${gcpCredential} --project=${env.param_gcp_project}
                            """

                            terraformRun("apply", "gke_create", "-var=\"agent_cidr=${env.agentWanIp}/32\"")

                            sh """
                            # Authorize Kube api access
                            gcloud container clusters get-credentials ${env.param_cluster_name} --zone ${env.param_gcp_zone} --project=${env.param_gcp_project}
                            """
                        }
                        stage('Init HELM') {
                            terraformRun("apply", "helm_init")
                            sh """
                            # Init Helm repo (workaround for https://github.com/terraform-providers/terraform-provider-helm/issues/23)
                            helm init --client-only
                            """
                        }
                        stage('Setup K8S Legion dependencies') {
                            terraformRun("apply", "k8s_setup")
                            sh """
                            # TODO: move cleanup to post stage
                            gcloud container clusters update ${env.param_cluster_name} --zone ${env.param_gcp_zone} --no-enable-master-authorized-networks
                            """
                        }
                    }
                }
            }
        }
    }
}

def terminateCluster() {
    withCredentials([
    file(credentialsId: "vault-${env.param_profile}", variable: 'vault')]) {
        withAWS(credentials: 'kops') {
            wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
                docker.image("${env.param_docker_repo}/k8s-ansible:${env.param_legion_infra_version}").inside("-e HOME=/opt/legion -v ${WORKSPACE}/profiles:/opt/legion/profiles -u root") {
                    stage('Terminate cluster') {
                        sh """
                        cd ${ansibleHome} && \
                        ansible-playbook terminate-cluster.yml \
                        ${ansibleVerbose} \
                        --vault-password-file=${vault} \
                        --extra-vars "profile=${env.param_profile}"
                        """
                    }
                }
            }
        }
    }
}

def deployLegion() {
    withCredentials([
    file(credentialsId: "vault-${env.param_profile}", variable: 'vault')]) {
        withAWS(credentials: 'kops') {
            wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
                docker.image("${env.param_docker_repo}/k8s-ansible:${env.param_legion_infra_version}").inside("-e HOME=/opt/legion -v ${WORKSPACE}/profiles:/opt/legion/profiles -u root") {
                    stage('Deploy Legion') {
                        sh """
                        cd ${ansibleHome} && \
                        ansible-playbook deploy-legion.yml \
                        ${ansibleVerbose} \
                        --vault-password-file=${vault} \
                        --extra-vars "profile=${env.param_profile} \
                        legion_version=${env.param_legion_version}  \
                        pypi_repo=${env.param_pypi_repo} \
                        helm_repo=${env.param_helm_repo} \
                        docker_repo=${env.param_docker_repo} \
                        model_reference=${commitID}"
                        """
                    }
                }
            }
        }
    }
}

def deployLegionToGCP() {
    withCredentials([
    file(credentialsId: "${env.gcpCredential}", variable: 'gcpCredential')]) {
        withCredentials([
        file(credentialsId: "${env.param_cluster_name}-gcp-secrets", variable: 'secrets')]) {
            withAWS(credentials: 'kops') {
                wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
                    docker.image("${env.param_docker_repo}/k8s-terraform:${env.param_legion_infra_version}").inside("-e GOOGLE_CREDENTIALS=${gcpCredential} -u root") {
                        stage('Deploy Legion') {
                            sh """
                            set -ex
                            # Authorize GCP access
                            gcloud auth activate-service-account --key-file=${gcpCredential} --project=${env.param_gcp_project}

                            # Setup Kube api access
                            gcloud container clusters get-credentials ${env.param_cluster_name} --zone ${env.param_gcp_zone} --project=${env.param_gcp_project}
                            gcloud container clusters update ${env.param_cluster_name} --zone ${env.param_gcp_zone} --enable-master-authorized-networks --master-authorized-networks "${env.agentWanIp}/32"

                            # Init Helm repo (workaround for https://github.com/terraform-providers/terraform-provider-helm/issues/23)
                            helm init --client-only
                            """
                            
                            tfDeployVars = "-var=\"legion_infra_version=${env.param_legion_infra_version}\" \
                            -var=\"legion_version=${env.param_legion_version}\" \
                            -var=\"legion_helm_repo=${env.param_helm_repo}\" \
                            -var=\"docker_repo=${env.param_docker_repo}\""

                            terraformRun("apply", "legion", "${tfDeployVars}")
                        }
                    }
                }
            }
        }
    }
}

def destroyGcpCluster() {
    withCredentials([
    file(credentialsId: "${env.gcpCredential}", variable: 'gcpCredential')]) {
        withCredentials([
        file(credentialsId: "${env.param_cluster_name}-gcp-secrets", variable: 'secrets')]) {
            withAWS(credentials: 'kops') {
                wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
                    docker.image("${env.param_docker_repo}/k8s-terraform:${env.param_legion_infra_version}").inside("-e GOOGLE_CREDENTIALS=${gcpCredential} -u root") {
                        stage('Setup cluster access') {
                            sh """
                            set -ex
                            # Authorize GCP access
                            gcloud auth activate-service-account --key-file=${gcpCredential} --project=${env.param_gcp_project}

                            # Setup Kube api access
                            gcloud container clusters get-credentials ${env.param_cluster_name} --zone ${env.param_gcp_zone} --project=${env.param_gcp_project}
                            gcloud container clusters update ${env.param_cluster_name} --zone ${env.param_gcp_zone} --enable-master-authorized-networks --master-authorized-networks "${env.agentWanIp}/32"

                            # Init Helm repo (workaround for https://github.com/terraform-providers/terraform-provider-helm/issues/23)
                            helm init --client-only
                            """
                        }

                        stage('Destroy legion TF state') {
                            terraformRun("destroy", "legion")
                        }

                        stage('Destroy legion TF state') {
                            terraformRun("destroy", "k8s_setup")
                        }

                        stage('Destroy k8s_setup TF state') {
                            terraformRun("destroy", "k8s_setup")
                        }

                         stage('Destroy helm_init TF state') {
                            terraformRun("destroy", "helm_init")
                        }

                         stage('Destroy gke_create TF state') {
                            terraformRun("destroy", "gke_create", "-var=\"agent_cidr=${env.agentWanIp}/32\"")
                        }
                    }
                }
            }
        }
    }
}

def legionScope(Closure body) {
    withCredentials([file(credentialsId: "vault-${env.param_profile}", variable: 'vault')]) {
        withAWS(credentials: 'kops') {
            docker.image("${env.param_docker_repo}/legion-pipeline-agent:${env.param_legion_version}").inside("-e HOME=/opt/legion -v ${WORKSPACE}/profiles:/opt/legion/profiles -u root") {
                downloadSecrets(vault)
                sh """
                    kubectl config set-context \$(kubectl config current-context) --namespace=${env.param_legion_namespace}
                    legionctl login --edi https://edi-${env.param_legion_namespace}.${env.param_profile} --token "${env.param_dex_token}"
                """

                body()
            }
        }
    }
}

def updateTLSCert() {
    withCredentials([
    file(credentialsId: "vault-${env.param_profile}", variable: 'vault')]) {
        withAWS(credentials: 'kops') {
            wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
                docker.image("${env.param_docker_repo}/k8s-ansible:${env.param_legion_infra_version}").inside("-e HOME=/opt/legion -v ${WORKSPACE}/profiles:/opt/legion/profiles -u root") {
                    stage('Reissue TLS Certificates') {
                        sh """
                        cd ${ansibleHome} && \
                        ansible-playbook update-tls-certificate.yml \
                        ${ansibleVerbose} \
                        --vault-password-file=${vault} \
                        --extra-vars "profile=${env.param_profile} \
                        vault_pass=${vault}"
                        """
                    }
                }
            }
        }
    }
}

def downloadSecrets(String vault) {
    sh """
        set -e
        export CLUSTER_NAME="${env.param_profile}"
        export PATH_TO_PROFILE_FILE="profiles/${env.param_profile}.yml"
        export CLUSTER_STATE_STORE=\"\$(yq -r .state_store \$PATH_TO_PROFILE_FILE)\"
        echo \"Loading kubectl config from \$CLUSTER_STATE_STORE for cluster \$CLUSTER_NAME\"
        export CREDENTIAL_SECRETS=".secrets.yaml"

        aws s3 cp \$CLUSTER_STATE_STORE/vault/${env.param_profile} \$CLUSTER_NAME
        ansible-vault decrypt --vault-password-file=${vault} --output \$CREDENTIAL_SECRETS \$CLUSTER_NAME

        kops export kubecfg --name \$CLUSTER_NAME --state \$CLUSTER_STATE_STORE
    """
}

def setupGcpAccess() {
    sh """
        set -ex
        # Authorize GCP access
        gcloud auth activate-service-account --key-file=${gcpCredential} --project=${env.param_gcp_project}

        # Setup Kube api access
        gcloud container clusters get-credentials ${env.param_cluster_name} --zone ${env.param_gcp_zone} --project=${env.param_gcp_project}
        gcloud container clusters update ${env.param_cluster_name} --zone ${env.param_gcp_zone} --enable-master-authorized-networks --master-authorized-networks "${env.agentWanIp}/32,86.57.255.92/32"
        
        # Setup firewall rule
        gcloud compute firewall-rules create ${env.param_cluster_name}-jenkins-access \
        --project=${env.param_gcp_project} --network=${env.param_cluster_name}-vpc \
        --description "Allow incoming traffic from Jenkins agent" \
        --allow tcp:443 --direction INGRESS --source-ranges="${env.agentWanIp}/32"

    """
}

def revokeGcpAccess() {
    withCredentials([
    file(credentialsId: "${env.gcpCredential}", variable: 'gcpCredential')]) {
        wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
            docker.image("${env.param_docker_repo}/k8s-terraform:${env.param_legion_infra_version}").inside("-e GOOGLE_CREDENTIALS=${gcpCredential} -u root") {
                stage('Revoke jenkins access') {
                    sh """
                        # Authorize GCP access
                        gcloud auth activate-service-account --key-file=${gcpCredential} --project=${env.param_gcp_project}

                        # Revoke Kube api access
                        gcloud container clusters update ${env.param_cluster_name} --zone ${env.param_gcp_zone} --no-enable-master-authorized-networks ||true

                        # Revoke agent access
                        gcloud compute firewall-rules delete ${env.param_cluster_name}-jenkins-access --project=${env.param_gcp_project} --quiet ||true
                    """
                }
            }
        }
    }
}

def runRobotTests(tags="") {
    withCredentials([
    file(credentialsId: "${env.credentials_name}", variable: 'vault')]) {
        withAWS(credentials: 'kops') {
            wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
                docker.image("${env.param_docker_repo}/legion-pipeline-agent:${env.param_legion_version}").inside("-e HOME=/opt/legion -v ${WORKSPACE}/profiles:/opt/legion/profiles -u root") {
                    stage('Run Robot tests') {
                        dir("${WORKSPACE}"){
                            def tags_list = tags.toString().trim().split(',')
                            def robot_tags = []
                            def nose_tags = []

                            for (item in tags_list) {
                                if (item.startsWith('-')) {
                                    item = item.replace("-","")
                                    robot_tags.add(" -e ${item}")
                                    nose_tags.add(" -a !${item}")
                                    }
                                else if (item?.trim()) {
                                    robot_tags.add(" -i ${item}")
                                    nose_tags.add(" -a ${item}")
                                }
                            }

                            env.robot_tags= robot_tags.join(" ")
                            env.nose_tags = nose_tags.join(" ")

                            downloadSecrets(vault)

                            sh """
                                cp .secrets.yaml /opt/legion/ && cd /opt/legion

                                echo "Starting robot tests"
                                make CLUSTER_NAME=${env.param_profile} \
                                     LEGION_VERSION=${env.param_legion_version} e2e-robot || true

                                echo "Starting python tests"
                                make CLUSTER_NAME=${env.param_profile} \
                                     LEGION_VERSION=${env.param_legion_version} e2e-python || true

                                cp -R target/ ${WORKSPACE}
                            """

                            robot_report = sh(script: 'find target/ -name "*.xml" | wc -l', returnStdout: true)

                            if (robot_report.toInteger() > 0) {
                                step([
                                    $class : 'RobotPublisher',
                                    outputPath : 'target/',
                                    outputFileName : "*.xml",
                                    disableArchiveOutput : false,
                                    passThreshold : 100,
                                    unstableThreshold: 95.0,
                                    onlyCritical : true,
                                    otherFiles : "*.png",
                                ])
                            }
                            else {
                                echo "No '*.xml' files for generating robot report"
                                currentBuild.result = 'UNSTABLE'
                            }

                            if (fileExists('target/nosetests.xml')) {
                                junit 'target/nosetests.xml'
                            }
                            else {
                                echo "No '*.xml' files for generating nosetests report"
                                currentBuild.result = 'UNSTABLE'
                            }

                            // Cleanup
                            sh "rm -rf ${WORKSPACE}/target/"
                        }
                    }
                }
            }
        }
    }
}

def runRobotTestsAtGcp(tags="") {
    withCredentials([
    file(credentialsId: "${env.gcpCredential}", variable: 'gcpCredential')]) {
        withCredentials([
        file(credentialsId: "${env.credentials_name}-tests", variable: 'testcreds')]) {
            withAWS(credentials: 'kops') {
                wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
                    docker.image("${env.param_docker_repo}/legion-pipeline-agent:${env.param_legion_version}").inside("-e HOME=/opt/legion -u root") {
                        stage('Run Robot tests') {
                            dir("${WORKSPACE}"){
                                def tags_list = tags.toString().trim().split(',')
                                def robot_tags = []
                                def nose_tags = []

                                for (item in tags_list) {
                                    if (item.startsWith('-')) {
                                        item = item.replace("-","")
                                        robot_tags.add(" -e ${item}")
                                        nose_tags.add(" -a !${item}")
                                        }
                                    else if (item?.trim()) {
                                        robot_tags.add(" -i ${item}")
                                        nose_tags.add(" -a ${item}")
                                    }
                                }

                                env.robot_tags= robot_tags.join(" ")
                                env.nose_tags = nose_tags.join(" ")

                                setupGcpAccess()

                                sh """
                                    cp ${testcreds} /opt/legion/.secrets.yaml 
                                    cd /opt/legion 
                                    mkdir /opt/legion/profiles
                                    ln -sf /opt/legion/.secrets.yaml /opt/legion/profiles/${env.param_full_cluster_name}.yml

                                    echo "Starting robot tests"
                                    make GOOGLE_APPLICATION_CREDENTIALS=${gcpCredential} \
                                         CLUSTER_NAME=${env.param_full_cluster_name} \
                                         CREDENTIAL_SECRETS=/opt/legion/.secrets.yaml \
                                         PATH_TO_PROFILES_DIR=/opt/legion/profiles/ \
                                         LEGION_VERSION=${env.param_legion_version} e2e-robot || true

                                    echo "Starting python tests"
                                    make GOOGLE_APPLICATION_CREDENTIALS=${gcpCredential} \
                                         CLUSTER_NAME=${env.param_full_cluster_name} \
                                         CREDENTIAL_SECRETS=/opt/legion/.secrets.yaml \
                                         PATH_TO_PROFILES_DIR=/opt/legion/profiles/ \
                                         LEGION_VERSION=${env.param_legion_version} e2e-python || true

                                    cp -R target/ ${WORKSPACE}
                                """

                                robot_report = sh(script: 'find target/ -name "*.xml" | wc -l', returnStdout: true)

                                if (robot_report.toInteger() > 0) {
                                    step([
                                        $class : 'RobotPublisher',
                                        outputPath : 'target/',
                                        outputFileName : "*.xml",
                                        disableArchiveOutput : false,
                                        passThreshold : 100,
                                        unstableThreshold: 95.0,
                                        onlyCritical : true,
                                        otherFiles : "*.png",
                                    ])
                                }
                                else {
                                    echo "No '*.xml' files for generating robot report"
                                    currentBuild.result = 'UNSTABLE'
                                }

                                if (fileExists('target/nosetests.xml')) {
                                    junit 'target/nosetests.xml'
                                }
                                else {
                                    echo "No '*.xml' files for generating nosetests report"
                                    currentBuild.result = 'UNSTABLE'
                                }

                                // Cleanup
                                sh "rm -rf ${WORKSPACE}/target/"
                            }
                        }
                    }
                }
            }
        }
    }
}

def deployLegionEnclave() {
    withCredentials([
        file(credentialsId: "vault-${env.param_profile}", variable: 'vault')]) {
        withAWS(credentials: 'kops') {
            wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
                docker.image("${env.param_docker_repo}/k8s-ansible:${env.param_legion_infra_version}").inside("-e HOME=/opt/legion/ansible -v ${WORKSPACE}/profiles:/opt/legion/profiles -u root") {
                    stage('Deploy Legion') {
                        sh """
                        cd ${ansibleHome} && \
                        ansible-playbook deploy-legion.yml \
                        ${ansibleVerbose} \
                        --vault-password-file=${vault} \
                        --extra-vars "profile=${env.param_profile} \
                        legion_version=${env.param_legion_version} \
                        pypi_repo=${env.param_pypi_repo} \
                        docker_repo=${env.param_docker_repo} \
                        helm_repo=${env.param_helm_repo} \
                        enclave_name=${env.param_enclave_name}"
                        """
                    }
                }
            }
        }
    }
}

def terminateLegionEnclave() {
    withCredentials([
        file(credentialsId: "vault-${env.param_profile}", variable: 'vault')]) {
        withAWS(credentials: 'kops') {
            wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
                docker.image("${env.param_docker_repo}/k8s-ansible:${env.param_legion_infra_version}").inside("-e HOME=/opt/legion/ansible -v ${WORKSPACE}//profiles:/opt/legion/profiles -u root") {
                    stage('Terminate Legion Enclave') {
                        sh """
                        cd ${ansibleHome} && \
                        ansible-playbook terminate-legion-enclave.yml \
                        ${ansibleVerbose} \
                        --vault-password-file=${vault} \
                        --extra-vars "profile=${env.param_profile} \
                        enclave_name=${env.param_enclave_name}"
                        """
                    }
                }
            }
        }
    }
}

def cleanupClusterSg(String cleanupContainerVersion) {
    withCredentials([
    file(credentialsId: "vault-${env.param_profile}", variable: 'vault')]) {
        withAWS(credentials: 'kops') {
            wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
                docker.image("${env.param_docker_repo}/k8s-ansible:${cleanupContainerVersion}").inside("-e HOME=/opt/legion -v ${WORKSPACE}/profiles:/opt/legion/profiles -u root") {
                    stage('Cleanup Cluster SG') {
                        sh """
                        cd ${ansibleHome} && \
                        ansible-playbook cleanup-cluster-sg.yml \
                        ${ansibleVerbose} \
                        --vault-password-file=${vault} \
                        --extra-vars "profile=${env.param_profile}" 
                        """
                    }
                }
            }
        }
    }
}

def authorizeJenkinsAgent() {
    withCredentials([
    file(credentialsId: "vault-${env.param_profile}", variable: 'vault')]) {
        withAWS(credentials: 'kops') {
            wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
                docker.image("${env.param_docker_repo}/k8s-ansible:${env.param_legion_infra_version}").inside("-e HOME=/opt/legion -v ${WORKSPACE}/profiles:/opt/legion/profiles -u root") {
                    sh """
                    cd ${ansibleHome} && \
                    ansible-playbook authorize-jenkins-agent.yml \
                    ${ansibleVerbose} \
                    --vault-password-file=${vault} \
                    --extra-vars "profile=${env.param_profile}" 
                    """
                }
            }
        }
    }
}

def terraformRun(command, tfModule, extraVars='') {
    sh """ #!/bin/bash -xe
        cd ${terraformHome}/env_types/${env.param_cluster_type}/${tfModule}/

        export TF_DATA_DIR=/tmp/.terraform-${env.param_cluster_name}-${tfModule}
        
        terraform init -backend-config="bucket=${env.param_cluster_name}-tfstate"

        if [ ${command} = "apply" ]; then
            terraform plan ${extraVars} \
            -var-file=${secrets} \
            -var-file=../../../env_profiles/${env.param_cluster_name}.tfvars
        fi

        echo "Execute ${command} on ${tfModule} state"

        terraform ${command} -auto-approve ${extraVars} \
        -var-file=${secrets} \
        -var-file=../../../env_profiles/${env.param_cluster_name}.tfvars
    """
}

def setBuildMeta(updateVersionScript) {

    Globals.rootCommit = sh returnStdout: true, script: 'git rev-parse --short HEAD 2> /dev/null | sed  "s/\\(.*\\)/\\1/"'
    Globals.rootCommit = Globals.rootCommit.trim()
    println("Root commit: " + Globals.rootCommit)

    def buildDate = sh returnStdout: true, script: "date '+%Y%m%d%H%M%S' | tr -d '\n'"

    Globals.dockerCacheArg = (env.param_enable_docker_cache.toBoolean()) ? '' : '--no-cache'
    println("Docker cache args: " + Globals.dockerCacheArg)

    wrap([$class: 'BuildUser']) {
        BUILD_USER = binding.hasVariable('BUILD_USER') ? "${BUILD_USER}" : "null"
    }

    // Set Docker labels
    Globals.dockerLabels = "--label git_revision=${Globals.rootCommit} --label build_id=${env.BUILD_NUMBER} --label build_user='${BUILD_USER}' --label build_date=${buildDate}"
    println("Docker labels: " + Globals.dockerLabels)

    // Define build version
    if (env.param_stable_release.toBoolean()) {
        if (env.param_release_version ) {
            Globals.buildVersion = sh returnStdout: true, script: "python ${updateVersionScript} --build-version=${env.param_release_version} ${env.BUILD_NUMBER} '${BUILD_USER}' ${buildDate}"
        } else {
            print('Error: ReleaseVersion parameter must be specified for stable release')
            exit 1
        }
    } else {
        Globals.buildVersion = sh returnStdout: true, script: "python ${updateVersionScript} ${env.BUILD_NUMBER} '${BUILD_USER}' ${buildDate}"
    }

    Globals.buildVersion = Globals.buildVersion.replaceAll("\n", "")

    env.BuildVersion = Globals.buildVersion

    currentBuild.description = "${Globals.buildVersion} ${env.param_git_branch}"
    print("Build version " + Globals.buildVersion)
    print('Building shared artifact')
    envFile = 'file.env'
    sh """
    rm -f $envFile
    touch $envFile
    echo "LEGION_VERSION=${Globals.buildVersion}" >> $envFile
    """
    archiveArtifacts envFile
    sh "rm -f $envFile"

}

def setGitReleaseTag() {
    print('Set Release tag')
    sshagent(["${env.param_git_deploy_key}"]) {
        sh """
        if [ `git tag |grep -x ${env.param_release_version}` ]; then
            if [ ${env.param_force_tag_push} = "true" ]; then
                echo 'Removing existing git tag'
                git tag -d ${env.param_release_version}
                git push origin :refs/tags/${env.param_release_version}
            else
                echo 'Specified tag already exists!'
                exit 1
            fi
        fi
        git tag ${env.param_release_version}
        git push origin ${env.param_release_version}
        """
    }
}

def notifyBuild(String buildStatus = 'STARTED') {
    // build status of null means successful
    buildStatus =  buildStatus ?: 'SUCCESSFUL'

    def previousBuild = currentBuild.getPreviousBuild()
    def previousBuildResult = previousBuild != null ? previousBuild.result : null

    def currentBuildResultSuccessful = buildStatus == 'SUCCESSFUL' || buildStatus == 'SUCCESS'
    def previousBuildResultSuccessful = previousBuildResult == 'SUCCESSFUL' || previousBuildResult == 'SUCCESS'

    def masterOrDevelopBuild = env.param_git_branch == 'origin/develop' || env.param_git_branch == 'origin/master'

    print("NOW SUCCESSFUL: ${currentBuildResultSuccessful}, PREV SUCCESSFUL: ${previousBuildResultSuccessful}, MASTER OR DEV: ${masterOrDevelopBuild}")

    // Default values
    def colorCode = '#FF0000'
    def arguments = ""
    if (env.param_legion_version) {
        arguments = arguments + "\nversion *${env.param_legion_version}*"
    }
    else {
        if (env.param_legion_infra_version) {
            arguments = arguments + "\nversion *${env.param_legion_infra_version}*"
        }
    }
    
    def mailSubject = "${buildStatus}: Job '${env.JOB_NAME} [${env.BUILD_NUMBER}]'"
    def summary = """\
    @here Job *${env.JOB_NAME}* #${env.BUILD_NUMBER} - *${buildStatus}* (previous: ${previousBuildResult}) \n
    Branch: *${GitBranch}* \n
    Profile: *<https://${env.param_profile}|${env.param_profile}>* \n
    Arguments: ${arguments} \n
    Manage: <${env.BUILD_URL}|Open>, <${env.BUILD_URL}/consoleFull|Full logs>, <${env.BUILD_URL}/parameters/|Parameters>
    """.stripIndent()

    // Override default values based on build status
    if (buildStatus == 'UNSTABLE') {
        colorCode = '#FFFF00'
    } else if (buildStatus == 'SUCCESS') {
        colorCode = '#00FF00'
    } else {
        colorCode = '#FF0000'
    }

    /// Notify everyone about each Nightly build
    if ("${env.JOB_NAME}".contains("Legion_CI_Nightly")) {
        slackSend (color: colorCode, message: summary)
        emailext (
            subject: mailSubject,
            body: summary,
            to: "${env.DevTeamMailList}"
        )
    /// Notify committers about CI builds
    } else if ("${env.JOB_NAME}".contains("Legion_CI")) {
        emailext (
            subject: mailSubject,
            body: summary,
            recipientProviders: [[$class: 'DevelopersRecipientProvider']]
        )
    /// Notify everyone about failed Master or Develop branch builds
    } else if (!currentBuildResultSuccessful && masterOrDevelopBuild) {
        slackSend (color: colorCode, message: summary)
        emailext (
            subject: mailSubject,
            body: summary,
            to: "${env.DevTeamMailList}"
        )
    }

}

def buildLegionImage(legion_image, build_context=".", dockerfile='Dockerfile', additional_parameters='') {
    dir (build_context) {
        
        def cache_from_params = ''

        if (env.param_enable_docker_cache.toBoolean()) {
            // Get list of base images from a Dockerfile
            base_images = sh(script: "grep 'FROM ' ${dockerfile} | awk '{print \$2}'", returnStdout: true).split('\n')

            println("Found following base images: ${base_images}")

            for (image in base_images) {
                sh "docker pull ${image} || true"
                cache_from_params += " --cache-from=${image}"
            }

            if (legion_image) {
                cache_image = "${env.param_docker_registry}/${legion_image}:${env.param_docker_cache_source}"

                cache_from_params += " --cache-from=${cache_image}"
                sh "docker pull ${cache_image} || true"
            }
        }

        sh """
            docker build ${Globals.dockerCacheArg} \
                         --build-arg version="${Globals.buildVersion}" \
                         --build-arg pip_extra_index_params="--extra-index-url ${env.param_pypi_repository}" \
                         --build-arg pip_legion_version_string="==${Globals.buildVersion}" \
                         ${cache_from_params} \
                         ${additional_parameters} \
                         -t legion/${legion_image}:${Globals.buildVersion} \
                         ${Globals.dockerLabels} -f ${dockerfile} .
        """
    }
}

def uploadDockerImage(String imageName) {
    if (env.param_stable_release.toBoolean()) {
        sh """
        # Push stable image to local registry
        docker tag legion/${imageName}:${Globals.buildVersion} ${env.param_docker_registry}/${imageName}:${Globals.buildVersion}
        docker tag legion/${imageName}:${Globals.buildVersion} ${env.param_docker_registry}/${imageName}:latest
        docker push ${env.param_docker_registry}/${imageName}:${Globals.buildVersion}
        docker push ${env.param_docker_registry}/${imageName}:latest
        # Push stable image to DockerHub
        docker tag legion/${imageName}:${Globals.buildVersion} ${env.param_docker_hub_registry}/${imageName}:${Globals.buildVersion}
        docker tag legion/${imageName}:${Globals.buildVersion} ${env.param_docker_hub_registry}/${imageName}:latest
        docker push ${env.param_docker_hub_registry}/${imageName}:${Globals.buildVersion}
        docker push ${env.param_docker_hub_registry}/${imageName}:latest
        """
    } else {
        sh """
        docker tag legion/${imageName}:${Globals.buildVersion} ${env.param_docker_registry}/${imageName}:${Globals.buildVersion}
        docker push ${env.param_docker_registry}/${imageName}:${Globals.buildVersion}
        """
    }
}

def updateVersionString(String versionFile) {
    //Update version.py file in legion package with new version string
    print('Update Legion package version string')
    if (env.param_next_version){
        sshagent(["${env.param_git_deploy_key}"]) {
            sh """
            git reset --hard
            git checkout develop
            sed -i -E "s/__version__.*/__version__ = \'${nextVersion}\'/g" ${versionFile}
            git commit -a -m "Bump Legion version to ${nextVersion}" && git push origin develop
            """
        }
    } else {
        throw new Exception("next_version must be specified with update_version_string parameter")
    }
}

def updateMasterBranch() {
    sshagent(["${env.param_git_deploy_key}"]) {
        sh """
        git reset --hard
        git checkout develop
        git checkout master && git pull -r origin master
        git pull -r origin develop
        git push origin master
        """
    }
}

def uploadHelmCharts(String pathToCharts) {
    dir (pathToCharts) {
        chartNames = sh(returnStdout: true, script: 'ls').split()
        println (chartNames)
        for (chart in chartNames){
            sh """
                export HELM_HOME="\$(pwd)"
                helm init --client-only
                helm dependency update "${chart}"
                helm package --version "${Globals.buildVersion}" "${chart}"
            """
        }
    }
    withCredentials([[
    $class: 'UsernamePasswordMultiBinding',
    credentialsId: 'nexus-local-repository',
    usernameVariable: 'USERNAME',
    passwordVariable: 'PASSWORD']]) {
        dir (pathToCharts) {
            script {
                for (chart in chartNames){
                sh"""
                curl -u ${USERNAME}:${PASSWORD} ${env.param_helm_repository} --upload-file ${chart}-${Globals.buildVersion}.tgz
                """
                }
            }
        }
    }
    // Upload stable release
    if (env.param_stable_release.toBoolean()) {
        //checkout repo with existing charts  (needed for generating correct repo index file )
        sshagent(["${env.param_git_deploy_key}"]) {
            sh """
            mkdir ~/.ssh || true
            ssh-keyscan github.com >> ~/.ssh/known_hosts
            git clone ${env.param_helm_repo_git_url} && cd ${WORKSPACE}/legion-helm-charts
            git checkout ${env.param_helm_repo_git_branch}
            """
        }
        //move packed charts to folder (where repo was checkouted)
        for (chart in chartNames){
            sh"""
            cd ${WORKSPACE}/legion-helm-charts
            mkdir -p ${WORKSPACE}/legion-helm-charts/${chart}
            mv ${pathToCharts}/${chart}-${Globals.buildVersion}.tgz ${WORKSPACE}/legion-helm-charts/${chart}/
            git add ${chart}/${chart}-${Globals.buildVersion}.tgz
            """
        }
        sshagent(["${env.param_git_deploy_key}"]) {
            sh """
            cd ${WORKSPACE}/legion-helm-charts
            helm repo index ./
            git add index.yaml
            git status
            git commit -m "Release ${Globals.buildVersion}"
            git push origin ${env.param_helm_repo_git_branch}
            """
        }
    }

    // Cleanup directory
    sh """
    rm -rf ${WORKSPACE}/legion-helm-charts
    rm -rf ${pathToCharts}
    """

}

return this
