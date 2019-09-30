def buildDescription(){
   if (env.param_cluster_name) {
        currentBuild.description = "${env.param_cluster_name} ${env.param_git_branch}"
    } else {
        currentBuild.description = "${env.param_profile} ${env.param_git_branch}"
    }
}

def createCluster(cloudCredsSecret, dockerArgPrefix) {
    withCredentials([
    file(credentialsId: "${cloudCredsSecret}", variable: 'cloudCredentials')]) {
        withCredentials([
        file(credentialsId: "${env.hieraPrivatePKCSKey}", variable: 'PrivatePkcsKey')]) {
            withCredentials([
            file(credentialsId: "${env.hieraPublicPKCSKey}", variable: 'PublicPkcsKey')]) {
                wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
                    def dockerArgs = """-e PROFILE=${env.clusterProfile}
                                        -u root
                                        ${dockerArgPrefix}${cloudCredentials}
                                     """
                    docker.image("${env.param_docker_repo}/k8s-terraform:${env.param_legion_infra_version}").inside(dockerArgs) {
                        stage('Extract Hiera data') {
                            extractHiera()
                        }
                        stage('Create Legion Cluster') {
                            // Update default cluster parameters
                            updateProfileKey("legion_infra_version", env.param_legion_infra_version)
                            updateProfileKey("legion_version", env.param_legion_version)
                            updateProfileKey("legion_helm_repo", env.param_helm_repo)
                            updateProfileKey("docker_repo", env.param_docker_repo)
                            updateProfileKey("model_reference", commitID)

                            sh'tf_runner -v create'
                        }
                        stage('Create cluster specific private DNS zone') {
                            if (env.param_cloud_provider == 'gcp') {
                                // Run terraform DNS state to establish DNS peering between Jenkins agent and target cluster
                                root_domain = sh(script: "jq -r '.root_domain' ${env.clusterProfile}", returnStdout: true).trim()
                                tfExtraVars = "-var=\"zone_type=FORWARDING\" \
                                    -var=\"zone_name=${env.param_cluster_name}.${root_domain}\" \
                                    -var=\"networks_to_add=[\\\"infra-vpc\\\"]\""
                                terraformRun("apply", "cluster_dns", "${tfExtraVars}", "${WORKSPACE}/legion-cicd/terraform/env_types/cluster_dns", "bucket=${env.param_cluster_name}-tfstate")
                            }
                        }
                    }
                }
            }
        }
    }
}

def destroyCluster(cloudCredsSecret, dockerArgPrefix) {
    withCredentials([
    file(credentialsId: "${cloudCredsSecret}", variable: 'cloudCredentials')]) {
        withCredentials([
        file(credentialsId: "${env.hieraPrivatePKCSKey}", variable: 'PrivatePkcsKey')]) {
            withCredentials([
            file(credentialsId: "${env.hieraPublicPKCSKey}", variable: 'PublicPkcsKey')]) {
                wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
                    def dockerArgs = """-e PROFILE=${env.clusterProfile}
                                        -u root
                                        ${dockerArgPrefix}${cloudCredentials}
                                     """
                    docker.image("${env.param_docker_repo}/k8s-terraform:${env.param_legion_infra_version}").inside(dockerArgs) {
                        stage('Extract Hiera data') {
                            extractHiera()
                        }
                        stage('Destroy Legion Cluster') {
                            // Update default cluster parameters
                            updateProfileKey("legion_infra_version", env.param_legion_infra_version)
                            updateProfileKey("legion_version", env.param_legion_version)
                            updateProfileKey("legion_helm_repo", env.param_helm_repo)
                            updateProfileKey("docker_repo", env.param_docker_repo)

                            sh'tf_runner -v destroy'
                        }
                        stage('Destroy cluster specific private DNS zone') {
                            if (env.param_cloud_provider == 'gcp') {
                                root_domain = sh(script: "jq -r '.root_domain' ${env.clusterProfile}", returnStdout: true).trim()
                                tfExtraVars = "-var=\"zone_type=FORWARDING\" \
                                    -var=\"zone_name=${env.param_cluster_name}.${root_domain}\""
                                terraformRun("destroy", "cluster_dns", "${tfExtraVars}", "${WORKSPACE}/legion-cicd/terraform/env_types/cluster_dns", "bucket=${env.param_cluster_name}-tfstate")
                            }
                        }
                        stage('Cleanup workspace') {
                            // Cleanup profiles directory
                            sh"rm -rf ${WORKSPACE}/legion-profiles/ ||true"
                        }
                    }
                }
            }
        }
    }
}

def setupGcpAccess() {
    sh """
        set -ex

        # Authorize GCP access
        gcloud auth activate-service-account --key-file=${gcpCredential} --project=${gcp_project_id}

        # Setup Kube api access
        gcloud container clusters get-credentials ${env.param_cluster_name} --zone ${gcp_zone}
        """
}

def runRobotTestsAtGcp(tags="") {
    withCredentials([
    file(credentialsId: "${env.gcpCredential}", variable: 'gcpCredential')]) {
        withCredentials([
        file(credentialsId: "${env.hieraPrivatePKCSKey}", variable: 'PrivatePkcsKey')]) {
            withCredentials([
            file(credentialsId: "${env.hieraPublicPKCSKey}", variable: 'PublicPkcsKey')]) {
                withAWS(credentials: 'kops') {
                    wrap([$class: 'AnsiColorBuildWrapper', colorMapName: "xterm"]) {
                        docker.image("${env.param_docker_repo}/k8s-terraform:${env.param_legion_infra_version}").inside("-e GOOGLE_CREDENTIALS=${gcpCredential} -e CLUSTER_NAME=${env.param_cluster_name} -u root") {
                            stage('Extract Hiera data') {
                                extractHiera()
                                gcp_zone = sh(script: "jq '.location' ${env.clusterProfile}", returnStdout: true)
                                gcp_project_id = sh(script: "jq '.project_id' ${env.clusterProfile}", returnStdout: true)
                            }
                        }
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
                                        cd /opt/legion
                                        make CLUSTER_PROFILE=${env.clusterProfile} \
                                             CLUSTER_NAME=${env.param_cluster_name} \
                                             DOCKER_REGISTRY=${env.param_docker_repo} \
                                             LEGION_VERSION=${env.param_legion_version} setup-e2e-robot

                                        echo "Starting robot tests"
                                        make GOOGLE_APPLICATION_CREDENTIALS=${gcpCredential} \
                                             CLUSTER_PROFILE=${env.clusterProfile} \
                                             ROBOT_THREADS=6 \
                                             LEGION_VERSION=${env.param_legion_version} e2e-robot || true

                                        make CLUSTER_PROFILE=${env.clusterProfile} \
                                             CLUSTER_NAME=${env.param_cluster_name} cleanup-e2e-robot

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
                                            unstableThreshold: 50.0,
                                            onlyCritical : true,
                                            otherFiles : "*.png",
                                        ])
                                    }
                                    else {
                                        echo "No '*.xml' files for generating robot report"
                                        currentBuild.result = 'UNSTABLE'
                                    }

                                    // Cleanup tests files
                                    sh "rm -rf ${WORKSPACE}/target/"

                                    // Cleanup profiles directory
                                    sh"rm -rf ${env.clusterProfile} ||true"
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

def terraformRun(command, tfModule, extraVars='', workPath="${terraformHome}/env_types/${env.param_cluster_type}/${tfModule}/", backendConfigBucket="bucket=${env.param_cluster_name}-tfstate", varFile="${env.clusterProfile}") {
    sh """ #!/bin/bash -xe
        cd ${workPath}

        export TF_DATA_DIR=/tmp/.terraform-${env.param_cluster_name}-${tfModule}
        
        terraform init -no-color -backend-config="${backendConfigBucket}"
        
        echo "Execute ${command} on ${tfModule} state"

        if [ ${tfModule} = "cluster_dns" ]; then
            terraform ${command} -no-color -auto-approve -var-file=${varFile} ${extraVars}
        elif [ ${command} = "apply" ]; then
            terraform plan -no-color -var-file=${varFile} ${extraVars}
            terraform ${command} -no-color -auto-approve -var-file=${varFile} ${extraVars}
        else
            terraform ${command} -no-color -auto-approve -var-file=${varFile} ${extraVars}
        fi
    """
}

def updateProfileKey(profilePath=env.clusterProfile, key, value) {
	contentReplace(
	    configs: [
	        fileContentReplaceConfig(
	            configs: [
	                fileContentReplaceItemConfig(
	                    search: "\"${key}.*",
	                    replace: "\"${key}\": \"${value}\",")
	                ],
	            fileEncoding: 'UTF-8',
	            filePath: profilePath)
	        ])
}

def extractHiera() {
    // export vars
    sh """#!/bin/bash -ex
    cat ${PrivatePkcsKey} > legion-profiles/private_key.pkcs7.pem
    cat ${PublicPkcsKey} > legion-profiles/public_key.pkcs7.pem
    cp tools/hiera_exporter legion-profiles

    cd legion-profiles && python3 hiera_exporter \
    --hiera-config hiera.yaml \
    --vars-template ../vars_template.yaml \
    --hiera-environment ${env.param_cluster_name} \
    --hiera-cloud ${env.param_cloud_provider} \
    --output-format json \
    --output-file "${env.clusterProfile}"
    chmod 777 ${env.clusterProfile} ${WORKSPACE}/legion-profiles/*
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

def setGitReleaseTag(git_deploy_key) {
    print('Set Release tag')
    sshagent([git_deploy_key]) {
        sh """#!/bin/bash -ex
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
