FROM jenkins/jenkins:lts
USER root
COPY plugins.txt /usr/share/jenkins/ref/plugins.txt
RUN /usr/local/bin/install-plugins.sh < /usr/share/jenkins/ref/plugins.txt
ENV JAVA_OPTS="-Djenkins.install.runSetupWizard=false"

ENV CASC_JENKINS_CONFIG="/var/jenkins_casc_configs/jcac.yaml"
COPY jcac.yaml $CASC_JENKINS_CONFIG

# -----------------------------------------------------------------------------
# SET VARIABLES USED IN THE JCAC.YAML FILE (used in the web UI)

# SSH Jenkins Agent which we want to connect to
ENV JENKINS_AGENT_NAME="Agent1"
ENV JENKINS_AGENT_IP_ADDR="192.168.9.2"
ENV JENKINS_AGENT_USER_HOME_DIR="/home/jenkins"
ENV JENKINS_AGENT_REMOTE_DIR="$JENKINS_AGENT_USER_HOME_DIR/jenkins_agent_dir"

# WEB UI LOGIN: Jenkins Master Admin
ENV JENKINS_WEB_UI_ADMIN_USER="admin"
ENV JENKINS_WEB_UI_ADMIN_PASSWD="admin"
ENV JENKINS_WEB_UI_ADMIN_EMAIL="admin@admin.com"

# PIPELINE Variables: Github repository we want Jenkins to conect to
ENV GITHUB_USERNAME="<github-username>"
ENV GITHUB_TOKEN="<githum-token>"
ENV GITHUB_REPO_NAME="solutions-terraform-jenkins-gitops"
