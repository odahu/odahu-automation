pipeline {
    agent { label 'ec2orchestrator'}

    environment {
        //Input parameters
        param_git_branch = "${params.GitBranch}"
        param_cluster_name = "${params.ClusterName}"
        param_legion_infra_version = "${params.LegionInfraVersion}"
        param_legion_version = "${params.LegionVersion}"
        param_docker_repo = "${params.DockerRepo}"
        param_helm_repo = "${params.HelmRepo}"
        param_gcp_zone = "${params.GcpZone}"
        param_gcp_project = "${params.GcpProject}"
        param_deploy_legion = "${params.DeployLegion}"
        param_use_regression_tests = "${params.UseRegressionTests}"
        param_tests_tags = "${params.TestsTags}"
        //Job parameters
        gcpCredential = "gcp-epmd-legn-legion-automation"
        sharedLibPath = "pipelines/legionPipeline.groovy"
        cleanupContainerVersion = "latest"
        terraformHome =  "/opt/legion/terraform"
        credentials_name = "${params.ClusterName}-gcp-secrets"
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
                script {
                    legion = load "${env.sharedLibPath}"
                    legion.getWanIp()
                    legion.buildDescription()
                }
            }
        }

        stage('Deploy Legion') {
            when {
                expression { return param_deploy_legion == "true" }
            }
            steps {
                script {
                    legion.deployLegionToGCP()
                }
            }
        }

        stage('Run regression tests'){
            when {
                expression { return param_use_regression_tests == "true" }
            }
            steps {
                script {
                    legion.ansibleDebugRunCheck(env.param_debug_run)
                    legion.runRobotTestsAtGcp(env.param_tests_tags ?: "")
                }
            }
        }
    }
    
    post {
        always {
            script {
                legion = load "${env.sharedLibPath}"
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