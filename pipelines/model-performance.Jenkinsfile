pipeline {
    agent { label 'ec2orchestrator'}

    environment {
        //Input parameters
        param_git_branch = "${params.GitBranch}"
        param_profile = "${params.Profile}"
        param_legion_version = "${params.LegionVersion}"
        param_legion_infra_version = "${params.LegionInfraVersion}"
        param_use_regression_tests = "${params.UseRegressionTests}"
        param_tests_tags = "${params.TestsTags}"
        param_docker_repo = "${params.DockerRepo}"
        param_debug_run = "false"
        //Job parameters
        sharedLibPath = "pipelines/legionPipeline.groovy"
        commitID = null
        cleanupContainerVersion = "latest"
        ansibleHome =  "/opt/legion/ansible"
        ansibleVerbose = '-v'
        helmLocalSrc = 'false'
        param_dex_token = "${params.DexToken}"
        param_model_performance_script = "${params.ModelPerformanceScript}"
        param_model_branch_name = "${params.ModelBranchName}"
        param_model_git_url = "${params.ModelGitUrl}"
        param_legion_namespace = "${params.LegionNamespace}"
        param_number_of_requests = "${params.NumberOfRequests}"
        param_number_of_clients = "${params.NumberOfClients}"
        param_hatch_rate = "${params.HatchRate}"
        param_model_git_verify_host = "${params.ModelGitVerifyHost}"
        param_model_git_jenkins_credential_id = "${params.modelGitJenkinsCredentialID}"
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
                script {
                    legion = load "${env.sharedLibPath}"
                    withCredentials([file(credentialsId: "${env.param_model_git_jenkins_credential_id}", variable: 'git_key')]) {
                        dir("${WORKSPACE}/ml_source") {
                            if (env.param_model_git_verify_host?.trim()) {
                                sh "ssh-keyscan -t rsa ${env.param_model_git_verify_host} >> ~/.ssh/known_hosts"
                            }
                            sh """
                                GIT_SSH_COMMAND='ssh -i ${git_key}' git clone ${env.param_model_git_url} .
                                GIT_SSH_COMMAND='ssh -i ${git_key}' git checkout ${env.param_model_branch_name}
                            """
                        }
                    }
                }
            }
        }

        stage('Authorize Jenkins Agent') {
            steps {
                script {
                    legion.ansibleDebugRunCheck(env.param_debug_run)
                    legion.authorizeJenkinsAgent()
                }
            }
        }

        stage('Tests') {
            steps {
                script {
                    legion.legionScope {
                        dir("${WORKSPACE}/ml_source") {
                            sh """
                                export MODEL_SERVER_URL="https://edge-${env.param_legion_namespace}.${env.param_profile}"
                                pip3 install locustio==0.8.1
                                locust -f ${env.param_model_performance_script} --no-web -c ${env.param_number_of_clients} -r ${env.param_hatch_rate} -n ${env.param_number_of_requests} --host "https://edge-${env.param_legion_namespace}.${env.param_profile}" --logfile "locust.log"
                            """

                            archiveArtifacts "locust.log"
                        }
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
        }
        cleanup {
            script {
                legion.ansibleDebugRunCheck(env.param_debug_run)
                legion.cleanupClusterSg(env.param_legion_infra_version ?: cleanupContainerVersion)
            }
            deleteDir()
        }
    }
}