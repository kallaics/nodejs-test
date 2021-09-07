pipeline {
    agent {
        docker {
            image 'node:6-alpine'
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
                
                // Integration test
                sh 'echo "Integration test"'

                app.inside {            
                    sh 'echo "Tests passed"'        
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

    }
}
