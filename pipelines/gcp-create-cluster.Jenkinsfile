pipeline {
    agent { label 'ec2orchestrator'}

    environment {
        //Input parameters
        param_git_branch = "${params.GitBranch}"
        param_cluster_name = "${params.ClusterName}"
        param_cluster_type = "${params.ClusterType}"
        param_legion_infra_version = "${params.LegionInfraVersion}"
        param_legion_version = "${params.LegionVersion}"
        param_docker_repo = "${params.DockerRepo}"
        param_helm_repo = "${params.HelmRepo}"
        param_deploy_legion = "${params.DeployLegion}"
        param_use_regression_tests = "${params.UseRegressionTests}"
        param_tests_tags = "${params.TestsTags}"
        param_cloud_provider = "${params.cloudProvider}"
        param_legion_cicd_repo = "${params.CicdRepoGitUrl}"
        param_legion_cicd_branch = "${params.CicdRepoGitBranch}"
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
                        if [ ! -d "legion-profiles" ]; then
                            GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git clone ${env.param_legion_profiles_repo} legion-profiles
                        fi
                        cd legion-profiles && git checkout ${env.param_legion_profiles_branch}
                        """
                    }
                    // Checkout CICD repo with private DNS zone
                    sshagent(["${env.legionCicdGitlabKey}"]) {
                        sh"""
                        if [ ! -d "legion-cicd" ]; then
                            GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no" git clone ${env.param_legion_cicd_repo} legion-cicd
                        fi
                        cd legion-cicd && git checkout ${env.param_legion_cicd_branch}
                        """
                    }
                }
            }
        }

        stage('Create Legion Cluster') {
            when {
                expression { return param_deploy_legion == "true" }
            }
            steps {
                script {
                    legion.createGCPCluster()
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
