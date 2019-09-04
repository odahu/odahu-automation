pipeline {
    agent { label 'ec2orchestrator'}

    environment {
        //Input parameters
        param_git_branch = "${params.GitBranch}"
        param_cluster_name = "${params.ClusterName}"
        param_cluster_type = "${params.ClusterType}"
        param_legion_infra_version = "${params.LegionInfraVersion}"
        param_docker_repo = "${params.DockerRepo}"
        param_helm_repo = "${params.HelmRepo}"
        param_gcp_project = "${params.GcpProject}"
        param_gcp_zone = "${params.GcpZone}"
        legionCicdGitlabKey = "legion-profiles-gitlab-key"
        param_legion_cicd_repo = "${params.CicdRepoGitUrl}"
        param_legion_cicd_branch = "${params.CicdRepoGitBranch}"
        param_cloud_provider = "${params.cloudProvider}"
        param_legion_profiles_repo = "${params.LegionProfilesRepo}"
        param_legion_profiles_branch = "${params.LegionProfilesBranch}"
        //Job parameters
        gcpCredential = "gcp-epmd-legn-legion-automation"
        sharedLibPath = "pipelines/legionPipeline.groovy"
        cleanupContainerVersion = "latest"
        terraformHome =  "/opt/legion/terraform"
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

                    sshagent(["${env.legionCicdGitlabKey}"]) {
                        sh"""
                        ssh-keyscan git.epam.com >> ~/.ssh/known_hosts
                        git clone ${env.param_legion_cicd_repo} legion-cicd
                        cd legion-cicd && git checkout ${env.param_legion_cicd_branch}
                        """
                    }
                }
            }
        }

        stage('Delete all Legion States') {
            steps {
                script {
                    legion.destroyGcpCluster()
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
