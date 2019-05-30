pipeline {
    agent { label 'ec2orchestrator'}

    environment {
        //Input parameters
        param_git_branch = "${params.GitBranch}"
        cluster_name = "${params.ClusterName}"
        param_legion_infra_version = "${params.LegionInfraVersion}"
        param_docker_repo = "${params.DockerRepo}"
        param_helm_repo = "${params.HelmRepo}"
        param_gcp_project = "${param.gcpProject}"
        //Job parameters
        gcpCredential = "gcp-epmd-legn-legion-automation"
        sharedLibPath = "pipelines/legionPipeline.groovy"
        cleanupContainerVersion = "latest"
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
                script {
                    legion.getWanIp()
                    legion = load "${env.sharedLibPath}"
                    legion.buildDescription()
                }
            }
        }

        stage('Create Kubernetes Cluster') {
            steps {
                script {
                    legion.createGCPCluster()
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
            }
            deleteDir()
        }
    }
}