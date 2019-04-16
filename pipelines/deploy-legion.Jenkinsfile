pipeline {
    agent { label 'ec2orchestrator'}

    environment {
        //Input parameters
        param_git_branch = "${params.GitBranch}"
        param_profile = "${params.Profile}"
        param_legion_version = "${params.LegionVersion}"
        param_legion_infra_version = "${params.LegionInfraVersion}"
        param_deploy_legion = "${params.DeployLegion}"
        param_use_regression_tests = "${params.UseRegressionTests}"
        param_tests_tags = "${params.TestsTags}"
        param_pypi_repo = "${params.PypiRepo}"
        param_docker_repo = "${params.DockerRepo}"
        param_helm_repo = "${params.HelmRepo}"
        param_debug_run = "${params.DebugRun}"
        param_commitID = "${params.commitID}"
        //Job parameters
        sharedLibPath = "pipelines/legionPipeline.groovy"
        commitID = null
        cleanupContainerVersion = "latest"
        ansibleHome =  "/opt/legion/ansible"
        ansibleVerbose = '-v'
        helmLocalSrc = 'false'
    }

    stages {
        stage('Checkout') {
            steps {
                cleanWs()
                checkout scm
                script {
                    sh 'echo RunningOn: $(curl http://checkip.amazonaws.com/)'
                    legion = load "${env.sharedLibPath}"
                    legion.buildDescription()

                    // Set legion release commit id
                    commitID = env.param_commitID ?: sh(script: "echo ${env.param_legion_version} | cut -f5 -d. | tr -d '\n'", returnStdout: true) 
                    print ("Legion commit ID: ${commitID}")

                    if (!(commitID)) {
                        print ('Can\'t get commit id for legion package')
                        currentBuild.result = 'FAILURE'
                        return
                    }
                }
            }
        }

        stage('Authorize Jenkins Agent') {
            steps {
                script {
                    legion.ansibleDebugRunCheck(env.param_debug_run)
                    legion.authorizeJenkinsAgent()
                }
            }
        }

        stage('Deploy Legion') {
            when {
                expression {return param_deploy_legion == "true" }
            }
            steps {
                script {
                    legion.ansibleDebugRunCheck(env.param_debug_run)
                    legion.deployLegion()
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
                    legion.runRobotTests(env.param_tests_tags ?: "")
                }
            }
        }
    }

    post {
        always {
            script {
                legion = load "${sharedLibPath}"
                legion.notifyBuild(currentBuild.currentResult)
            }
        }
        cleanup {
            script {
                legion.ansibleDebugRunCheck(env.param_debug_run)
                legion.cleanupClusterSg(env.param_legion_infra_version ?: cleanupContainerVersion)
            }
            deleteDir()
        }
    }
}