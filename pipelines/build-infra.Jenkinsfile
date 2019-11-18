import java.text.SimpleDateFormat

class Globals {
    static String rootCommit = null
    static String buildVersion = null
    static String dockerLabels = null
    static String dockerCacheArg = null
}

def chartNames = null

pipeline {
    agent { label 'ec2builder'}

    options{
            buildDiscarder(logRotator(numToKeepStr: '35', artifactNumToKeepStr: '35'))
        }
    environment {
            /// Input parameters
            //Enable docker cache parameter
            param_enable_docker_cache = "${params.EnableDockerCache}"
            //Build major version release and optionally push it to public repositories
            param_stable_release = "${params.StableRelease}"
            //Release version to tag all artifacts to
            param_release_version = "${params.ReleaseVersion}"
            //Git Branch to build package from
            param_git_branch = "${params.GitBranch}"
            //Push release git tag
            param_push_git_tag = "${params.PushGitTag}"
            //Rewrite git tag i exists
            param_force_tag_push = "${params.ForceTagPush}"
            //Push release to master bransh
            param_update_master = "${params.UpdateMaster}"
            //Upload legion python package to pypi
            param_upload_legion_package = "${params.UploadLegionPackage}"
            //Set next releases version explicitly
            param_next_version = "${params.NextVersion}"
            // Update version string
            param_update_version_string = "${params.UpdateVersionString}"
            // Release version to be used as docker cache source
            param_docker_cache_source = "${params.DockerCacheSource}"
            //Artifacts storage parameters
            param_helm_repo_git_url = "${params.HelmRepoGitUrl}"
            param_helm_repo_git_branch = "${params.HelmRepoGitBranch}"
            param_helm_repository = "${params.HelmRepository}"
            param_docker_registry = "${params.DockerRegistry}"
            param_docker_hub_registry = "${params.DockerHubRegistry}"
            param_git_deploy_key = "${params.GitDeployKey}"
            param_legion_profiles_repo = "${params.LegionProfilesRepo}"
            param_legion_profiles_branch = "${params.LegionProfilesBranch}"
            param_legion_cicd_repo = "${params.LegionCicdRepo}"
            param_legion_cicd_branch = "${params.LegionCicdBranch}"
            ///Job parameters
            legionProfilesGitlabKey = "legion-profiles-gitlab-key"
            legionCicdGitlabKey = "legion-profiles-gitlab-key"
            sharedLibPath = "legion-cicd/pipelines/legionPipeline.groovy"
            pathToCharts= "${WORKSPACE}/helms"

            param_dockerhub_publishing_enabled = "${params.DockerHubPublishingEnabled}"
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
                        print ("Checkout Legion-cicd repo")
                        sh"""#!/bin/bash -ex
                        mkdir -p \$(getent passwd \$(whoami) | cut -d: -f6)/.ssh && ssh-keyscan git.epam.com >> \$(getent passwd \$(whoami) | cut -d: -f6)/.ssh/known_hosts
                        if [ ! -d "legion-cicd" ]; then
                            git clone ${env.param_legion_cicd_repo} legion-cicd
                        fi
                        cd legion-cicd && git checkout ${env.param_legion_cicd_branch}
                        """

                        print ("Load legion pipeline common library")
                        cicdLibrary = load "${env.sharedLibPath}"
                    }

                    verFiles = [
                            'version.info'
                    ]
                    cicdLibrary.setBuildMeta(verFiles)
                }
            }
        }

        // Set Git Tag in case of stable release
        stage('Set GIT release Tag'){
            steps {
                script {
                    if (env.param_stable_release.toBoolean() && env.param_push_git_tag.toBoolean()){
                        cicdLibrary.setGitReleaseTag("${env.param_git_deploy_key}")

                        print("Set tag to profiles repo")
                        sshagent(["${env.legionProfilesGitlabKey}"]) {
                            sh"""
                            mkdir -p \$(getent passwd \$(whoami) | cut -d: -f6)/.ssh && ssh-keyscan git.epam.com >> \$(getent passwd \$(whoami) | cut -d: -f6)/.ssh/known_hosts
                            if [ ! -d "legion-profiles" ]; then
                                git clone ${env.param_legion_profiles_repo} legion-profiles
                            fi
                            cd legion-profiles && git checkout ${env.param_legion_profiles_branch}
                            """
                        }
                        dir("${WORKSPACE}/legion-profiles"){
                            cicdLibrary.setGitReleaseTag("${env.legionProfilesGitlabKey}")
                        }
                    }
                    else {
                        print("Skipping release git tag push")
                    }
                }
            }
        }

        stage("Build Docker images & Upload Helm charts") {
            parallel {
                stage("Build Terraform") {
                    steps {
                        script {
                            cicdLibrary.buildLegionImage('odahuflow-automation', ".", "containers/terraform/Dockerfile")
                            cicdLibrary.uploadDockerImage('odahuflow-automation', env.param_stable_release.toBoolean() && env.param_dockerhub_publishing_enabled.toBoolean())
                        }
                    }
                }
            }
        }

        stage('Package and upload helm charts'){
            steps {
                script {
                    cicdLibrary.uploadHelmCharts(env.pathToCharts)
                }
            }
        }

        stage("Update version string") {
            steps {
                script {
                    if (env.param_stable_release.toBoolean() && env.param_update_version_string.toBoolean()) {
                        cicdLibrary.updateVersionString(env.versionFile)
                    }
                    else {
                        print("Skipping version string update")
                    }
                }
            }
        }

        stage('Update Master branch'){
            steps {
                script {
                    if (env.param_update_master.toBoolean()){
                        cicdLibrary.updateMasterBranch()
                        }
                    else {
                        print("Skipping Master branch update")
                    }
                }
            }
        }

    }
    post {
        always {
            script {
                sh "sudo chmod -R 777 ${WORKSPACE}"
                dir ("${WORKSPACE}") {
                    cicdLibrary = load "${env.sharedLibPath}"
                    cicdLibrary.notifyBuild(currentBuild.currentResult)
                }
            }
            deleteDir()
        }
    }
}
