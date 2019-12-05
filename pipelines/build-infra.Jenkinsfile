import java.text.SimpleDateFormat

class Globals {
    static String rootCommit = null
    static String buildVersion = null
    static String dockerLabels = null
    static String dockerCacheArg = null
}

def chartNames = null

pipeline {
    agent { label 'ec2builder' }

    options {
        buildDiscarder(logRotator(numToKeepStr: '35', artifactNumToKeepStr: '35'))
    }
    environment {
        /*
        Job parameters
        */
        pathToCharts = "${WORKSPACE}/helms"
        sharedLibPath = "legion-cicd/pipelines/legionPipeline.groovy"
        //Git Branch to build package from
        param_git_branch = "${params.GitBranch}"

        /*
        Release parameters
        */
        //Set next releases version explicitly
        param_next_version = "${params.NextVersion}"
        //Release version to tag all artifacts to
        param_release_version = "${params.ReleaseVersion}"
        //Push release git tag
        param_push_git_tag = "${params.PushGitTag}"
        //Rewrite git tag i exists
        param_force_tag_push = "${params.ForceTagPush}"
        param_update_version_string = "${params.UpdateVersionString}"
        param_update_master = "${params.UpdateMaster}"
        //Build major version release and optionally push it to public repositories
        param_stable_release = "${params.StableRelease}"

        /*
        Helm
        */
        param_helm_repo_git_url = "${params.HelmRepoGitUrl}"
        param_helm_repo_git_branch = "${params.HelmRepoGitBranch}"
        param_helm_repository = "${params.HelmRepository}"

        /*
        Docker
        */
        param_dockerhub_publishing_enabled = "${params.DockerHubPublishingEnabled}"
        param_docker_registry = "${params.DockerRegistry}"
        param_docker_hub_registry = "${params.DockerHubRegistry}"
        param_enable_docker_cache = "${params.EnableDockerCache}"
        param_docker_cache_source = "${params.DockerCacheSource}"

        /*
        CICD repository
        */
        legionCicdGitlabKey = "${params.legionCicdGitlabKey}"
        param_git_deploy_key = "${params.GitDeployKey}"
        //Legion CICD repo url (for pipeline methods import)
        param_legion_cicd_repo = "${params.LegionCicdRepo}"
        //Legion repo branch (tag or branch name)
        param_legion_cicd_branch = "${params.LegionCicdBranch}"
    }

    stages {
        stage('Checkout and set build vars') {
            steps {
                cleanWs()
                checkout scm
                script {
                    sh 'echo RunningOn: $(curl http://checkip.amazonaws.com/)'

                    // import Legion components
                    sshagent(["${env.legionCicdGitlabKey}"]) {
                        print("Checkout Legion-cicd repo")
                        sh """#!/bin/bash -ex
                        mkdir -p \$(getent passwd \$(whoami) | cut -d: -f6)/.ssh && ssh-keyscan git.epam.com >> \$(getent passwd \$(whoami) | cut -d: -f6)/.ssh/known_hosts
                        if [ ! -d "legion-cicd" ]; then
                            git clone ${env.param_legion_cicd_repo} legion-cicd
                        fi
                        cd legion-cicd && git checkout ${env.param_legion_cicd_branch}
                        """

                        print("Load odahu pipeline common library")
                        cicdLibrary = load "${env.sharedLibPath}"
                    }

                    def verFiles = [
                            'version.info'
                    ]
                    cicdLibrary.setBuildMeta(verFiles)
                }
            }
        }

        stage("Build Docker images & Upload Helm charts") {
            parallel {
                stage("Build Terraform") {
                    steps {
                        script {
                            cicdLibrary.buildDockerImage('odahu-flow-automation', ".", "containers/terraform/Dockerfile")
                            cicdLibrary.uploadDockerImage('odahu-flow-automation', false)
                        }
                    }
                }
                stage("Build Fluentd Docker image") {
                    steps {
                        script {
                            cicdLibrary.buildDockerImage('odahu-flow-fluentd', 'containers/fluentd')
                            cicdLibrary.uploadDockerImage('odahu-flow-fluentd', env.param_stable_release.toBoolean() && env.param_dockerhub_publishing_enabled.toBoolean())
                        }
                    }
                }
            }
        }

        stage('Package and upload helm charts') {
            steps {
                script {
                    cicdLibrary.uploadHelmCharts(env.pathToCharts)
                }
            }
        }

        stage("Update branch") {
            steps {
                script {
                    cicdLibrary.updateReleaseBranches(
                            env.param_stable_release.toBoolean(),
                            env.param_push_git_tag.toBoolean(),
                            env.param_update_version_string.toBoolean(),
                            env.param_update_master.toBoolean(),
                            env.param_git_deploy_key)
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
