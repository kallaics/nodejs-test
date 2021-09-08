pipeline {
    agent {
        docker {
            image 'node:current-alpine'
            args '-p 3000:3000' 
        }
    }
 
    stages {

        stage('Code Checkout') {
            steps {
                checkout([
                    $class: 'GitSCM', 
                    branches: [[name: '*/${branch}']], 
                    userRemoteConfigs: [[url: 'https://github.com/kallaics/nodejs-test.git']]
                ])
            }
        }

        stage('Build') {
            
            agent {
                docker {
                    image 'docker/dind'
                    args '-v /var/run/docker/docker.sock:/var/run/docker/docker.sock' 
                }
            }

            steps {
                // Build a Docker container with the Node.JS code
                script {
                    app = docker.build("kallaics82/nodejs-test")
                }
            }
        }

        stage('Integration test') {
            steps {
                script {
                    app.inside {            
                        // Start integration test, when app is running well.
                        sh 'echo "Integration test"'
                    }
                }
            }

            post {
                success {
                    // Publish reports
                    publishHTML target: [
                        allowMissing: false,
                        alwaysLinkToLastBuild: false,
                        keepAll: true,
                        reportDir: 'coverage',
                        reportFiles: 'index.html',
                        reportName: 'RCov Report'
                    ]

                    script {
                        //Push Docker image to local registry
                        app.push("${env.BUILD_NUMBER}")
                    }
                }

            }
        }


        stage('Release') {
            // if it happened on the master branch (on GitHub "master" branch called "main")
            when {
                branch 'main'
            }

            steps {
                //Push Docker image to DockerHub
                script {
                    docker.withRegistry('https://registry.hub.docker.com', 'Docker Hub - kallaics82') {
                        // Push docker image with a build number.
                        app.push("${env.BUILD_NUMBER}")
                        // Push image with a "latest" tag.
                        app.push("latest")    
                    }
                }
            }
        }
    }

        // Notify user via e-mail about the job state after the run.
    post {   
        success {  
            notifyOnSuccessful()  
        }
        // "Unsuccessful" is included any state, except the success.
        // When it is too much, you can able to use "failure" keyword
        unsuccessful {  
            notifyOnFailure()
        }    
    }  
}

def notifyOnSuccessful() {
   // Send email to user
  emailext (
      subject: "Build was successsful: '${env.JOB_NAME}  [${env.BUILD_NUMBER}]'",
      body: """<p>Job: '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
        <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>""",
      recipientProviders: [[$class: 'DevelopersRecipientProvider']]
    )
}

def notifyOnFailure() {
   // Send email to user
  emailext (
      subject: "Build Failed! '${env.JOB_NAME} [${env.BUILD_NUMBER}]'",
      body: """<p>Job: '${env.JOB_NAME} [${env.BUILD_NUMBER}]':</p>
        <p>Check console output at &QUOT;<a href='${env.BUILD_URL}'>${env.JOB_NAME} [${env.BUILD_NUMBER}]</a>&QUOT;</p>""",
      recipientProviders: [[$class: 'DevelopersRecipientProvider']]
    )
}