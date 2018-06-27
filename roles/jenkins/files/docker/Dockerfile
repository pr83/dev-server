FROM jenkins/jenkins:latest

USER root

RUN curl -sL https://deb.nodesource.com/setup_6.x | bash -

RUN apt-get update && \
	apt-get install -y --no-install-recommends \
    nodejs \
    npm && \
    npm install --global gulp-cli

RUN /usr/local/bin/install-plugins.sh git matrix-auth workflow-aggregator docker-workflow blueocean credentials-binding postbuild-task

ENV JENKINS_USER admin
ENV JENKINS_PASS admin

ENV JAVA_OPTS -Djenkins.install.runSetupWizard=false

COPY default-user.groovy /usr/share/jenkins/ref/init.groovy.d/

COPY run.sh /usr/bin/run.sh

VOLUME /var/jenkins_home

ENTRYPOINT ["/bin/bash", "/usr/bin/run.sh"]