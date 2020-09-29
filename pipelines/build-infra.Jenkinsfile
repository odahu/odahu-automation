import java.text.SimpleDateFormat

class Globals {
    static String rootCommit = null
    static String buildVersion = null
    static String dockerLabels = null
    static String dockerCacheArg = null
}

def chartNames = null
def DefCheckoutTimeout = 5
def DefBuildTimeout = 10
def DefBuildBackupTimeout = 5
def DefUpdateTimeout = 5

pipeline {
    agent { label 'ec2builder' }

    options {
        buildDiscarder(logRotator(numToKeepStr: '35', artifactNumToKeepStr: '35'))
    }
    environment {
        /*
        Job parameters
        */
        //Git Branch to build package from
        param_git_branch = "${params.GitBranch}"
        param_checkout_timeout = "${params.CheckoutTimeout ?: DefCheckoutTimeout}"
        param_build_timeout = "${params.BuildTimeout ?: DefBuildTimeout}"
        param_build_backup_timeout = "${params.BuildBackupTimeout ?: DefBuildBackupTimeout}"
        param_update_timeout = "${params.UpdateTimeout ?: DefUpdateTimeout}"

        /*
        Release parameters
        */
        //Set next releases version explicitly
        param_next_version = "${params.NextVersion}"
        //Release version to tag all artifacts to
        param_release_version = "${params.ReleaseVersion}"
        //Push release git tag
        param_push_git_tag = "${params.PushGitTag}"
        //Rewrite git tag if exists
        param_force_tag_push = "${params.ForceTagPush}"
        param_update_version_string = "${params.UpdateVersionString}"
        param_update_master = "${params.UpdateMaster}"
        //Build major version release and optionally push it to public repositories
        param_stable_release = "${params.StableRelease}"

        /*
        Docker
        */
        param_dockerhub_publishing_enabled = "${params.DockerHubPublishingEnabled}"
        param_docker_registry = "${params.DockerRegistry}"
        param_docker_hub_registry = "${params.DockerHubRegistry}"
        param_enable_docker_cache = "${params.EnableDockerCache}"
        param_docker_cache_source = "${params.DockerCacheSource}"

        /*
        CI/CD repository
        */
        param_git_deploy_key = "${params.GitDeployKey}"
        // CI/CD repo url (for pipeline methods import)
        param_cicd_repo = "${params.LegionCicdRepo}"
        // CI/CD repo branch (tag or branch name)
        param_cicd_branch = "${params.LegionCicdBranch}"
        param_cicd_key = "${params.legionCicdGitlabKey}"
        param_cicd_shared_lib = "${params.cicdSharedLibPath}"
    }

    stages {
        stage('Checkout and set build vars') {
            steps {
                timeout(time: param_checkout_timeout, unit: 'MINUTES') {
                    cleanWs()
                    checkout scm
                    script {
                        // import CI/CD components
                        sshagent(["${env.param_cicd_key}"]) {
                            print("Checkout CI/CD repo")
                            sh """#!/bin/bash -ex
                                export GIT_SSH_COMMAND="ssh -o UserKnownHostsFile=/dev/null -o StrictHostKeyChecking=no"
                                if [ ! -d "cicd" ]; then
                                    git clone ${env.param_cicd_repo} cicd
                                fi
                                cd cicd && git checkout ${env.param_cicd_branch}
                            """

                            print("Load common CI/CD library")
                            cicdLibrary = load "${env.param_cicd_shared_lib}"
                        }

                        def verFiles = [
                            'version.info'
                        ]
                        cicdLibrary.setBuildMeta(verFiles, 'cicd')
                    }
                }
            }
        }

        stage("Build Terraform Docker image") {
            steps {
                timeout(time: param_build_timeout, unit: 'MINUTES') {
                    script {
                        cicdLibrary.buildDockerImage('odahu-flow-automation', ".", "containers/terraform/Dockerfile")
                        cicdLibrary.uploadDockerImage('odahu-flow-automation', false)
                    }
                }
            }
        }

        stage("Build PostgreSQL backup Docker image") {
            steps {
                timeout(time: param_build_backup_timeout, unit: 'MINUTES') {
                    script {
                        cicdLibrary.buildDockerImage('odahu-flow-pg-backup', ".", "containers/pg-backup/Dockerfile")
                        cicdLibrary.uploadDockerImage('odahu-flow-pg-backup', false)
                    }
                }
            }
        }

        stage("Update branch") {
            steps {
                timeout(time: param_update_timeout, unit: 'MINUTES') {
                    script {
                        cicdLibrary.updateReleaseBranches(
                            env.param_stable_release.toBoolean(),
                            env.param_push_git_tag.toBoolean(),
                            env.param_update_version_string.toBoolean(),
                            env.param_update_master.toBoolean(),
                            env.param_git_deploy_key
                        )
                    }
                }
            }
        }
    }
    post {
        always {
            script {
                sh "sudo chmod -R 777 ${WORKSPACE}"
                dir("${WORKSPACE}") {
                    cicdLibrary.notifyBuild(currentBuild.currentResult)
                }
            }
            deleteDir()
        }
    }
}
