pipeline {
    agent { label 'ec2orchestrator' }

    environment {
        //Input parameters
        param_git_branch = "${params.GitBranch}"
        param_cluster_name = "${params.ClusterName}"
        param_cluster_type = "${params.ClusterType}"
        param_legion_infra_version = "${params.LegionInfraVersion}"
        param_legion_version = "${params.LegionVersion}"
        param_docker_repo = "${params.DockerRepo}"
        param_helm_repo = "${params.HelmRepo}"
        param_gcp_zone = "${params.GcpZone}"
        param_gcp_project = "${params.GcpProject}"
        param_deploy_legion = "${params.DeployLegion}"
        param_use_regression_tests = "${params.UseRegressionTests}"
        param_tests_tags = "${params.TestsTags}"
        param_cloud_provider = "${params.cloudProvider}"
        param_legion_profiles_repo = "${params.LegionProfilesRepo}"
        param_legion_profiles_branch = "${params.LegionProfilesBranch}"
        //Job parameters
        full_cluster_name = "gke_${params.GcpProject}_${params.GcpZone}_${params.ClusterName}"
        gcpCredential = "gcp-epmd-legn-legion-automation"
        sharedLibPath = "pipelines/legionPipeline.groovy"
        cleanupContainerVersion = "latest"
        terraformHome = "/opt/legion/terraform"
        hieraPrivatePKCSKey = "hiera-pkcs-private-key"
        hieraPublicPKCSKey = "hiera-pkcs-public-key"
        legionProfilesGitlabKey = "legion-profiles-gitlab-key"
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

        stage('Run regression tests') {
            when {
                expression { return param_use_regression_tests == "true" }
            }
            steps {
                script {
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