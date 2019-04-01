pipeline {
    agent any

    environment {
        //Input parameters
        param_git_branch = "${params.GitBranch}"
        param_profile = "${params.Profile}"
        param_enable_docker_cache = "${params.EnableDockerCache}"
        param_deploy_legion = "${params.DeployLegion}"
        param_create_jenkins_tests = "${params.CreateJenkinsTests}"
        param_use_regression_tests = "${params.UseRegressionTests}"
        param_tests_tags = "${params.TestsTags}"
        param_pypi_repo = "${params.PypiRepo}"
        param_docker_repo = "${params.DockerRepo}"
        param_helm_repo = "${params.HelmRepo}"
        param_build_legion_job_name = "${params.BuildLegionInfraJobName}"
        param_terminate_cluster_job_name = "${params.TerminateClusterJobName}"
        param_create_cluster_job_name = "${params.CreateClusterJobName}"
        //Job parameters
        sharedLibPath = "pipelines/legionPipeline.groovy"
        legionInfraVersion = null
        commitID = null
        ansibleHome =  "/opt/legion/ansible"
        ansibleVerbose = '-v'
        helmLocalSrc = 'false'
        mergeBranch = "ci/${params.GitBranch}"
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
                script {
                    print('Set interim merge branch')
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

                    legion = load "${env.sharedLibPath}"
                    legion.buildDescription()
                    commitID = env.mergeBranch
                }
            }
        }

       stage('Build') {
           steps {
               script {
                   result = build job: env.param_build_legion_job_name, propagate: true, wait: true, parameters: [
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
                   copyArtifacts filter: '*', flatten: true, fingerprintArtifacts: true, projectName: env.param_build_legion_job_name, selector: specific      (buildNumber.toString()), target: ''
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
                   // Load variables

                   if (!legionInfraVersion) {
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
                           string(name: 'Profile', value: env.param_profile),
                   ]
               }
           }
       }

       stage('Create Cluster') {
           steps {
               script {
                   result = build job: env.param_create_cluster_job_name, propagate: true, wait: true, parameters: [
                           [$class: 'GitParameterValue', name: 'GitBranch', value: env.mergeBranch],
                           string(name: 'Profile', value: env.param_profile),
                           string(name: 'LegionInfraVersion', value: legionInfraVersion),
                           booleanParam(name: 'SkipKops', value: false)
                   ]
               }
           }
       }

       stage('Terminate Cluster') {
           steps {
               script {
                   result = build job: env.param_terminate_cluster_job_name, propagate: true, wait: true, parameters: [
                           [$class: 'GitParameterValue', name: 'GitBranch', value: env.mergeBranch],
                           string(name: 'LegionInfraVersion', value: legionInfraVersion),
                           string(name: 'Profile', value: env.param_profile),
                   ]
               }
           }
       }
    }

    post {
        always {
            script {
                legion = load "${sharedLibPath}"
                result = build job: env.param_terminate_cluster_job_name, propagate: true, wait: true, parameters: [
                        [$class: 'GitParameterValue', name: 'GitBranch', value: env.mergeBranch],
                        string(name: 'legionInfraVersion', value: legionInfraVersion),
                        string(name: 'Profile', value: env.param_profile)]

                legion.notifyBuild(currentBuild.currentResult)
            }
        }
        cleanup {
            script {
                print('Remove interim merge branch')
                sh """
                    if [ `git branch | grep ${env.mergeBranch}` ]; then
                        git branch -D ${env.mergeBranch}
                        git push origin --delete ${env.mergeBranch}
                    fi
                """
            }
            deleteDir()
        }
    }
}
