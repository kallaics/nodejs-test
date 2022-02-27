# nodejs-test
NodeJS  code test.

This repository contains a code for NodeJS builds with sample code.

The environment:
- GitHub (access and repo for the code)
- Docker Hub (access and repo for the images)
- Docker
- docker-compose command. 
- Jenkins Docker container (Source files are attached to the git repo)

Guide for users

We will do here a new environment, based on a Node.JS example code. The example code and some source file need to be uploaded to GitHub. The development environment will be created from a locally built Jenkins image. The Jenkins image will contains all of the plugin, that will required. The pipelines will be handled via Jenkinsfile in the Git repository (the multibranch pipeline wil be created manually first). The bult code will be prepared in docker image and these images will be stored locally and the releases (from master branch) will be uploaded to Docker Hub.


Deployment guide

1. Please check your GitHub and Docker Hub access and repos are prepared well.

- Upload your code to GitHub.
- Create your repo on Docker Hub

2. Build the Jenkins image on your device

    ```bash
    cd Jenkins-Docker-Image
    docker build --tag jenkins:v1
    ```

3. Deploy the Jenkins cluster

    You need to docker-compose already installed. If it is not installed yet, then please install it now.  
    [Install guide for Docker Compose](https://docs.docker.com/compose/install/)

    ```bash
    cd ../Jenkins-Docker-Compose-File
    docker-compose up -d 
    ```
    Warn: Please check your port 8080 is still not in use already!

4. When Jenkins is ready you can able to login via web UI.

    The default URL is: [http://127.0.0.1:8080](http://127.0.0.1:8080)

5. Login to Jenkins with the default credentials

    ```yaml
    username: admin
    password: jenkins
    ```
6. Check all plugin is up-to-date.

    - Click on "Manage Jenkins" on the left side.
    - Click on "Manage plugins"
    - If the "Update" tab is empty all of the plugin are up o date.

7. Create a new multibranch pipeline

    - Click on "New item" on top left.
    - Fill the form with the next parameters.

        * Description: Test repo
        * Branch sources: 
            * GitHub access: "Add" button and add your credentials
        * Behaviors:
            * Discover brances:
                * Strategy: Choose "Only brances that are also filed as PRs" from the list
            * Discover pull requests from orgin
                * Strategy: Choose "Merging the pull request with the current target branch revision" from the list
            * Discover pull request from forks:
                * Strategy: Choose "Merging the pull request with the current target branch revision" from the list
            * Trust:  
                Choose "From users with Admin or Write permission" from the list
            * Filter by name:
                * Regular expression: 
                    Type "(main|development|release.*|feature.*|bugfix.*)" (without double quotes!)
        * Orphaned iItem Strategy:
            * Discard old items: Check the checkbox
                * Days to keep old times (in days): 365
                * Max # of old items to keep: 10
        * Properties:
            * Docker registry URL: https://registry.hub.docker.com/
            * Registry credentials: Please add your Docker Hub credentials  with the "Add" button

    Click on "Save" button.

8. Create a Webhook on GitHb.

    - Open your repository on GitHub.
    - Choose a "Settings" option
    - Click on "Webhooks" on the menu in the left side.
    - Click on "Add webhook" button (on top right side).
    - Enter your password if is required.
    - Fill the form:
        * Payload URL: Add your Jenkins external URL here (you can use DNS or IP as well)  
        
            Notice: the URL need to be available from the Internet so please taker care of the security as well.
        * Content type: Choose "application/json" from the list.
    - Which events would you like to trigger this webhook? : "Send me everything"
    - Active: the checkbox need to be checked.
    - Click on "Add webhook" button.

9. Do a test with your code (push some changes)

    Notice: File "Jenkinsfile" also need to be added your code.

    Here is an example code for Jenkinsfile:

    ```java
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
    ```

10. Check the result in Jenkins.



