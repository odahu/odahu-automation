pipeline {
    agent { label 'ec2orchestrator'}

    environment {
        //Input parameters
        param_git_branch = "${params.GitBranch}"
        param_profile = "${params.Profile}"
        param_skip_kops = "${params.SkipKops}"
        param_legion_infra_version = "${params.LegionInfraVersion}"
        param_docker_repo = "${params.DockerRepo}"
        param_helm_repo = "${params.HelmRepo}"
        param_debug_run = "${params.DebugRun}"
        //Job parameters
        sharedLibPath = "pipelines/legionPipeline.groovy"
        ansibleHome =  "/opt/legion/ansible"
        ansibleVerbose = '-v'
        helmLocalSrc = 'false'
        cleanupContainerVersion = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
                script {
                    legion = load "${env.sharedLibPath}"
                    legion.buildDescription()
                }
            }
        }

        stage('Create Kubernetes Cluster') {
            steps {
                script {
                    legion.ansibleDebugRunCheck(env.param_debug_run)
                    legion.createCluster()
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
                legion = load "${env.sharedLibPath}"
                legion.cleanupClusterSg(param_legion_infra_version ?: cleanupContainerVersion)
            }
            deleteDir()
        }
    }
}