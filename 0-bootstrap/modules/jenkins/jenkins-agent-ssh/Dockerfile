FROM jenkins/ssh-agent

# -----------------------------------------------------------------------------
# SSH DAEMON SEETINGS - THE JENKINS AGENT IS A SSH SERVER

ENV SSHD_CONFIG_DIR="/etc/ssh"

# Setting up the sshd_config file
RUN sed -i $SSHD_CONFIG_DIR/sshd_config \
        -e 's/#PubkeyAuthentication.*/PubkeyAuthentication yes/' \
        -e 's/#AuthorizedKeysFile.*/AuthorizedKeysFile    \/etc\/ssh\/authorized_keys/'

# The Jenkins Agent needs the Master public key. This can be in your github repo
COPY authorized_keys $SSHD_CONFIG_DIR/authorized_keys

# Configure secure permissions on SSHD_CONFIG_DIR
RUN chmod 755 $SSHD_CONFIG_DIR \
 && chmod 655 $SSHD_CONFIG_DIR/authorized_keys

# -----------------------------------------------------------------------------
# JENKINS SEETINGS - TO RUN JOBS SENT BY THE MASTER
ENV JENKINS_AGENT_REMOTE_DIR="/home/jenkins/jenkins_agent_dir"

# Create the "Remote Jenkins directory" and set the jenkins user as owner
RUN mkdir "$JENKINS_AGENT_REMOTE_DIR" \
 && chmod 766 "$JENKINS_AGENT_REMOTE_DIR" \
 && chown jenkins "$JENKINS_AGENT_REMOTE_DIR"

# Make sure Jenkins Master can find the java version installed in the Agent
RUN JAVA_IN=$(which java) \
 && ln -s $JAVA_IN /usr/bin/java
