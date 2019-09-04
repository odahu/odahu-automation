pipeline {
    agent any

    environment {
        //Input parameters
        param_legion_git_branch = "${params.LegionGitBranch}"
        param_legion_infra_branch = "${params.LegionInfraGitBranch}"
        param_legion_cicd_branch = "${params.LegionCicdGitBranch}"
        param_legion_profiles_branch = "${params.LegionProfilesGitBranch}"
        param_cluster_name = "${params.ClusterName}"
        param_enable_docker_cache = "${params.EnableDockerCache}"
        param_deploy_legion = "${params.DeployLegion}"
        param_use_regression_tests = "${params.UseRegressionTests}"
        param_tests_tags = "${params.TestsTags}"
        param_pypi_repo = "${params.PypiRepo}"
        param_docker_repo = "${params.DockerRepo}"
        param_helm_repo = "${params.HelmRepo}"
        param_commitID = "${params.commitID}"
        param_remain_the_cluster = "${params.RemainTheCluster}"
        // Jobs names
        param_build_legion_job_name = "${params.BuildLegionJobName}"
        param_build_legion_infra_job_name = "${params.BuildLegionInfraJobName}"
        param_terminate_cluster_job_name = "${params.TerminateClusterJobName}"
        param_create_cluster_job_name = "${params.CreateClusterJobName}"
        param_deploy_legion_job_name = "${params.DeployLegionJobName}"
        //Job parameters
        sharedLibPath = "pipelines/legionPipeline.groovy"
        commitID = null
        legionInfraVersion = null
        legionVersion = null
        mergeBranch = "ci-infra/${params.LegionInfraGitBranch}"
        gcpCredential = "gcp-epmd-legn-legion-automation"
        terraformHome =  "/opt/legion/terraform"
        gitDeployKey = "epam-legion-deployment-key"
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
                script {
                    print('Set interim merge branch')
                    sshagent(["${env.gitDeployKey}"]) {
                        sh """
                        echo ${env.mergeBranch}
                        if [ `git branch | grep ${env.mergeBranch}` ]; then
                            echo 'Removing existing git tag'
                            git branch -D ${env.mergeBranch}
                            git push origin --delete ${env.mergeBranch}
                        fi
                        git branch ${env.mergeBranch}
                        git push origin ${env.mergeBranch}
                        """
                    }
                    legion = load "${env.sharedLibPath}"
                    legion.buildDescription()
                }
            }
        }

        stage('Build Legion Infrastructure artifacts') {
            steps {
                script {
                    result = build job: env.param_build_legion_infra_job_name, propagate: true, wait: true, parameters: [
                            [$class: 'GitParameterValue', name: 'GitBranch', value: env.mergeBranch],
                            string(name: 'EnableDockerCache', value: env.param_enable_docker_cache)
                    ]

                    buildNumber = result.getNumber()
                    print 'Finished build id ' + buildNumber.toString()

                    // Save logs
                    logFile = result.getRawBuild().getLogFile()
                    sh """
                    cat "${logFile.getPath()}" | perl -pe 's/\\x1b\\[8m.*?\\x1b\\[0m//g;' > build-log.txt 2>&1
                    """
                    archiveArtifacts 'build-log.txt'

                    // Copy artifacts
                    copyArtifacts filter: '*', flatten: true, fingerprintArtifacts: true, projectName: env.param_build_legion_infra_job_name, selector: specific      (buildNumber.toString()), target: ''
                    sh 'ls -lah'

                    // \ Load variables
                    def map = [:]
                    def envs = sh returnStdout: true, script: "cat file.env"

                    envs.split("\n").each {
                        kv = it.split('=', 2)
                        print "Loaded ${kv[0]} = ${kv[1]}"
                        map[kv[0]] = kv[1]
                    }

                    legionInfraVersion = map["LEGION_VERSION"]

                    print "Loaded version ${legionInfraVersion}"

                    if (!legionInfraVersion) {
                        error 'Cannot get legion release version number'
                    }
                }
            }
        }

        stage('Build Legion artifacts') {
            steps {
                script {
                    result = build job: env.param_build_legion_job_name, propagate: true, wait: true, parameters: [
                            [$class: 'GitParameterValue', name: 'GitBranch', value: env.param_legion_git_branch],
                            string(name: 'EnableDockerCache', value: env.param_enable_docker_cache)
                    ]

                    buildNumber = result.getNumber()
                    print 'Finished build id ' + buildNumber.toString()

                    // Save logs
                    logFile = result.getRawBuild().getLogFile()
                    sh """
                    cat "${logFile.getPath()}" | perl -pe 's/\\x1b\\[8m.*?\\x1b\\[0m//g;' > build-log.txt 2>&1
                    """
                    archiveArtifacts 'build-log.txt'

                    // Copy artifacts
                    copyArtifacts filter: '*', flatten: true, fingerprintArtifacts: true, projectName: env.param_build_legion_job_name, selector: specific       (buildNumber.toString()), target: ''
                    sh 'ls -lah'

                    // \ Load variables
                    def map = [:]
                    def envs = sh returnStdout: true, script: "cat file.env"

                    envs.split("\n").each {
                        kv = it.split('=', 2)
                        print "Loaded ${kv[0]} = ${kv[1]}"
                        map[kv[0]] = kv[1]
                    }

                    legionVersion = map["LEGION_VERSION"]

                    print "Loaded version ${legionVersion}"

                    if (!legionVersion) {
                        error 'Cannot get legion release version number'
                    }
                }
            }
        }

        stage('Terminate Cluster if exists') {
            steps {
                script {
                    result = build job: env.param_terminate_cluster_job_name, propagate: true, wait: true, parameters: [
                        [$class: 'GitParameterValue', name: 'GitBranch', value: env.mergeBranch],
                        string(name: 'LegionInfraVersion', value: legionInfraVersion),
                        string(name: 'ClusterName', value: env.param_cluster_name),
                        string(name: 'LegionProfilesBranch', value: env.param_legion_profiles_branch),
                        string(name: 'CicdRepoGitBranch', value: env.param_legion_cicd_branch)
                    ]
                }
            }
        }

        stage('Create Cluster') {
            steps {
                script {
                    result = build job: env.param_create_cluster_job_name, propagate: true, wait: true, parameters: [
                        [$class: 'GitParameterValue', name: 'GitBranch', value: env.mergeBranch],
                        string(name: 'ClusterName', value: env.param_cluster_name),
                        string(name: 'LegionInfraVersion', value: legionInfraVersion),
                        string(name: 'LegionProfilesBranch', value: env.param_legion_profiles_branch),
                        string(name: 'CicdRepoGitBranch', value: env.param_legion_cicd_branch)
                    ]
                }
            }
        }

        stage('Deploy Legion & run tests') {
            steps {
                script {
                    result = build job: env.param_deploy_legion_job_name, propagate: true, wait: true, parameters: [
                        [$class: 'GitParameterValue', name: 'GitBranch', value: env.mergeBranch],
                        string(name: 'ClusterName', value: env.param_cluster_name),
                        string(name: 'LegionVersion', value: legionVersion),
                        string(name: 'LegionInfraVersion', value: legionInfraVersion),
                        string(name: 'TestsTags', value: env.param_tests_tags ?: ""),
                        string(name: 'commitID', value: env.commitID),
                        booleanParam(name: 'DeployLegion', value: true),
                        booleanParam(name: 'UseRegressionTests', value: true),
                        string(name: 'LegionProfilesBranch', value: env.param_legion_profiles_branch)
                    ]
                }
            }
        }
    }

    post {
        always {
            script {
                if (env.param_remain_the_cluster.toBoolean()) {
                    print("Remaining the cluster for further investigateion")
                }
                else {
                    result = build job: env.param_terminate_cluster_job_name, propagate: true, wait: true, parameters: [
                           [$class: 'GitParameterValue', name: 'GitBranch', value: env.mergeBranch],
                           string(name: 'LegionInfraVersion', value: legionInfraVersion),
                           string(name: 'ClusterName', value: env.param_cluster_name),
                           string(name: 'LegionProfilesBranch', value: env.param_legion_profiles_branch),
                           string(name: 'CicdRepoGitBranch', value: env.param_legion_cicd_branch)
                    ]
                }
                print('Remove interim merge branch')
                sshagent(["${env.gitDeployKey}"]) {
                    sh """
                        if [ `git branch | grep ${env.mergeBranch}` ]; then
                            git branch -D ${env.mergeBranch}
                            git push origin --delete ${env.mergeBranch}
                        fi
                    """
                }
                legion = load "${env.sharedLibPath}"
                GitBranch = env.mergeBranch
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
