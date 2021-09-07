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
                        args '-p 3000:3000' 
                    }
                }

            steps {
                // Build a Docker container with the Node.JS code
                app = docker.build("kallaics82/nodejs-test")
            }
        }

        stage('Integration test') {
            steps {

                app.inside {            
                    // Start integration test, when app is running well.
                    sh 'echo "Integration test"'
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

                    //Push Docker image to DockerHub
                    docker.withRegistry('https://registry.hub.docker.com', 'git') {
                        // Push the image with the build number to the repository
                        app.push("${env.BUILD_NUMBER}")
                        // Mark image as a latest.
                        app.push("latest")        
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
                docker.withRegistry('https://registry.hub.docker.com', 'git') {
                    // Mark image as a latest.
                    app.push("latest")
                
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