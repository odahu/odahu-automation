pipeline {
    agent { label 'ec2orchestrator'}

    environment {
        //Input parameters
        param_git_branch = "${params.GitBranch}"
        param_profile = "${params.Profile}"
        param_legion_version = "${params.LegionVersion}"
        param_legion_infra_version = "${params.LegionInfraVersion}"
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
        param_vcs_name = "${params.VcsName}"
        param_model_file = "${params.ModelFile}"
        param_model_name = "${params.ModelName}"
        param_model_work_dir = "${params.ModelWorkDir}"
        param_model_branch_name = "${params.ModelBranchName}"
        param_model_git_url = "${params.ModelGitUrl}"
        param_model_git_jenkins_credential_id = "${params.modelGitJenkinsCredentialID}"
        param_legion_namespace = "${params.LegionNamespace}"
        param_use_regression_tests = "${params.UseRegressionTests}"
        param_model_git_verify_host = "${params.ModelGitVerifyHost}"
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
                script {
                    sh 'echo RunningOn: $(curl http://checkip.amazonaws.com/)'

                    legion = load "${env.sharedLibPath}"
                    currentBuild.description = "Model: ${env.param_model_name}"

                    if (!env.param_use_regression_tests.toBoolean()) {
                        return
                    }

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

        stage('Training') {
            steps {
                script {
                    legion.legionScope {
                        def modelDir = env.param_model_work_dir ?: ""
                        sh """
                            legionctl mt delete ${env.param_model_name} || true
                            legionctl mt create ${env.param_model_name} --timeout 400 --workdir '${modelDir}' --toolchain jupyter --vcs ${env.param_vcs_name} -e '${env.param_model_file}' --memory-limit 1Gi --cpu-limit 2046m --memory-request 128Mi --cpu-request 1024m
                        """
                    }
                }
            }
        }

        stage('Deployment') {
            steps {
                script {
                    legion.legionScope {
                        sh """
                            legionctl md delete ${env.param_model_name} --ignore-not-found
                            legionctl md create ${env.param_model_name} --image \$(kubectl get mt ${env.param_model_name} -o=jsonpath='{.status.modelImage}')
                        """
                    }
                }
            }
        }

        stage('Tests') {
            steps {
                script {
                    legion.legionScope {
                        if (!env.param_use_regression_tests.toBoolean()) {
                            return
                        }

                        dir("${WORKSPACE}/ml_source") {
                            sh """
                                pip3 install nose
                                export MODEL_SERVER_URL="https://edge-${env.param_legion_namespace}.${env.param_profile}"
                                export MODEL_ID="\$(kubectl get mt ${env.param_model_name} -o=jsonpath='{.status.id}')"
                                export MODEL_VERSION="\$(kubectl get mt ${env.param_model_name} -o=jsonpath='{.status.version}')"
                                nosetests ${env.param_model_work_dir}/tests --with-xunit --xunit-file "nosetests.xml"
                            """

                            junit "nosetests.xml"
                        }
                    }
                }
            }
        }
    }

    post {
        cleanup {
            script {
                legion.ansibleDebugRunCheck(env.param_debug_run)
                legion.cleanupClusterSg(env.param_legion_infra_version ?: cleanupContainerVersion)
            }
            deleteDir()
        }
    }
}