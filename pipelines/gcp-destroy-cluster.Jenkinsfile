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
        clusterProfile = "${WORKSPACE}/cluster_profile.json"
        legionProfilesGitlabKey = "legion-profiles-gitlab-key"
        legionCicdGitlabKey = "legion-profiles-gitlab-key"
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
                script {
                    legion = load "${env.sharedLibPath}"
                    legion.buildDescription()
                    // checkout repo with hieradata
                    sshagent(["${env.legionProfilesGitlabKey}"]) {
                        sh"""#!/bin/bash -ex
                        #TODO get repo url from passed parameters
                        mkdir -p \$(getent passwd \$(whoami) | cut -d: -f6)/.ssh && ssh-keyscan git.epam.com >> \$(getent passwd \$(whoami) | cut -d: -f6)/.ssh/known_hosts
                        if [ ! -d "legion-profiles" ]; then
                            git clone ${env.param_legion_profiles_repo} legion-profiles
                        fi
                        cd legion-profiles && git checkout ${env.param_legion_profiles_branch}
                        """
                    }
                    // Checkout CICD repo with private DNS zone
                    sshagent(["${env.legionCicdGitlabKey}"]) {
                        sh"""
                        mkdir -p \$(getent passwd \$(whoami) | cut -d: -f6)/.ssh && ssh-keyscan git.epam.com >> \$(getent passwd \$(whoami) | cut -d: -f6)/.ssh/known_hosts
                        if [ ! -d "legion-cicd" ]; then
                            git clone ${env.param_legion_cicd_repo} legion-cicd
                        fi
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
