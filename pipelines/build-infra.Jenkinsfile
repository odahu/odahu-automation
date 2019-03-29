import java.text.SimpleDateFormat

class Globals {
    static String rootCommit = null
    static String buildVersion = null
    static String dockerLabels = null
    static String dockerCacheArg = null
}

def chartNames = null

pipeline {
    agent { label 'ec2builder'}

    options{
            buildDiscarder(logRotator(numToKeepStr: '35', artifactNumToKeepStr: '35'))
        }
    environment {
            /// Input parameters
            //Enable docker cache parameter
            param_enable_docker_cache = "${params.EnableDockerCache}"
            //Build major version release and optionally push it to public repositories
            param_stable_release = "${params.StableRelease}"
            //Release version to tag all artifacts to
            param_release_version = "${params.ReleaseVersion}"
            //Git Branch to build package from
            param_git_branch = "${params.GitBranch}"
            //Push release git tag
            param_push_git_tag = "${params.PushGitTag}"
            //Rewrite git tag i exists
            param_force_tag_push = "${params.ForceTagPush}"
            //Push release to master bransh
            param_update_master = "${params.UpdateMaster}"
            //Upload legion python package to pypi
            param_upload_legion_package = "${params.UploadLegionPackage}"
            //Set next releases version explicitly
            param_next_version = "${params.NextVersion}"
            // Update version string
            param_update_version_string = "${params.UpdateVersionString}"
            // Release version to be used as docker cache source
            param_docker_cache_source = "${params.DockerCacheSource}"
            //Artifacts storage parameters
            param_helm_repo_git_url = "${params.HelmRepoGitUrl}"
            param_helm_repo_git_branch = "${params.HelmRepoGitBranch}"
            param_helm_repository = "${params.HelmRepository}"
            param_docker_registry = "${params.DockerRegistry}"
            param_docker_hub_registry = "${params.DockerHubRegistry}"
            param_git_deploy_key = "${params.GitDeployKey}"
            ///Job parameters
            sharedLibPath = "pipelines/legionPipeline.groovy"
            versionFile= "${WORKSPACE}/version.info"
            updateVersionScript = "tools/update_version_id"
            pathToCharts= "${WORKSPACE}/helms"
    }

    stages {
        stage('Checkout and set build vars') {
            steps {
                cleanWs()
                checkout scm
                script {
                    legion = load "${env.sharedLibPath}"
                    
                    print("Check code for security issues")
                    sh "bash install-git-secrets-hook.sh install_hooks && git secrets --scan -r"

                    legion.setBuildMeta(env.updateVersionScript)
                }
            }
        }

        // Set Git Tag in case of stable release
        stage('Set GIT release Tag'){
            steps {
                script {
                    if (env.param_stable_release && env.param_push_git_tag.toBoolean()){
                        legion.setGitReleaseTag()
                    }
                    else {
                        print("Skipping release git tag push")
                    }
                }
            }
        }

        stage("Docker login") {
            steps {
                withCredentials([[
                 $class: 'UsernamePasswordMultiBinding',
                 credentialsId: 'nexus-local-repository',
                 usernameVariable: 'USERNAME',
                 passwordVariable: 'PASSWORD']]) {
                    sh "docker login -u ${USERNAME} -p ${PASSWORD} ${env.param_docker_registry}"
                }
                script {
                    if (env.param_stable_release) {
                        withCredentials([[
                        $class: 'UsernamePasswordMultiBinding',
                        credentialsId: 'dockerhub',
                        usernameVariable: 'USERNAME',
                        passwordVariable: 'PASSWORD']]) {
                            sh "docker login -u ${USERNAME} -p ${PASSWORD}"
                        }
                    }
                }
            }
        }

        stage("Build Docker images & Upload Helm charts") {
            parallel {
                stage("Build Ansible") {
                    steps {
                        script {
                            legion.buildLegionImage('k8s-ansible', ".", "containers/ansible/Dockerfile")
                            legion.uploadDockerImage('k8s-ansible')
                        }
                    }
                }
                stage('Build kube-fluentd') {
                    steps {
                        script {
                            legion.buildLegionImage('k8s-kube-fluentd', "containers/kube-fluentd")
                            legion.uploadDockerImage('k8s-kube-fluentd')
                        }
                    }
                }
                stage('Build kube-elb-security') {
                    steps {
                        script {
                            legion.buildLegionImage('k8s-kube-elb-security', "containers/kube-elb-security")
                            legion.uploadDockerImage('k8s-kube-elb-security')
                        }
                    }
                }
                stage('Build oauth2-proxy') {
                    steps {
                        script {
                            legion.buildLegionImage('k8s-oauth2-proxy', "containers/oauth2-proxy")
                            legion.uploadDockerImage('k8s-oauth2-proxy')
                        }
                    }
                }
            }
        }

        stage('Package and upload helm charts'){
            steps {
                script {
                    legion.uploadHelmCharts(env.pathToCharts)
                }
            }
        }

        stage("Update version string") {
            steps {
                script {
                    if (env.param_stable_release && env.param_update_version_stringx) {
                        legion.updateVersionString(env.versionFile)
                    }
                    else {
                        print("Skipping version string update")
                    }
                }
            }
        }

        stage('Update Master branch'){
            steps {
                script {
                    if (env.param_update_master){
                        legion.updateMasterBranch()
                        print ("update master")
                        }
                    else {
                        print("Skipping Master branch update")
                    }
                }
            }
        }

    }
    post {
        always {
            script {
                legion = load "${sharedLibPath}"
                legion.notifyBuild(currentBuild.currentResult)
            }
            deleteDir()
        }
    }
}
