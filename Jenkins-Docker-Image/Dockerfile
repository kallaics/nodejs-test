# Create a new Jenkins container about the official Jenkins
FROM jenkins/jenkins:lts

# Environment variables with default values
# if you are using ARG instead of ENV, then you can able to override these values!
ENV JENKINS_USER admin
ENV JENKINS_PASS jenkins
ENV JENKINS_URL http://127.0.0.1:8080
ENV CLEAN_WORKING_DIR false

# Install plugins
RUN /usr/local/bin/install-plugins.sh git matrix-auth workflow-aggregator docker-workflow blueocean credentials-binding docker-plugin docker-workflow docker-build-step

# Disable first run wizzard (will be done by Groovy script)
ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

# Create user via Groovy script
COPY user.groovy /usr/share/jenkins/ref/init.groovy.d/

# Add volume for Jenkins home directory
VOLUME /var/jenkins_home
