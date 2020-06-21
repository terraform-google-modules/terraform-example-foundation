# Jenkins Infrastructure Deployment Pipeline
  - Jenkins Master on-prem + Jenkins Agents on GCE

# 1. Introduction
#### Terraform module
The Terraform module "jenkins_bootstrap" (provided in the parent directory) deploys the bootstrap pipeline. The bootstrap pipeline consists in:
  - A Google Cloud Platform project
  - A Jenkins Agent running in a Google Compute Engine instance (GCE) in container mode
  - among other GCP elements 
  - **TODO: expand this list**

#### Jenkins Agent
The Jenkins Agent is basically a simple SSH server with java installed on it. You can connect any Jenkins Master to it, which in turn, acts as an SSH Client.

To allow the Master to connect to the Agent and schedule jobs in it, you need:
  - The GCE instance (Jenkins Agent) must have the Master's public ssh key configured in the [GCE instance metadata](https://cloud.google.com/compute/docs/instances/adding-removing-ssh-keys). Copy the public key into the `jenkins-agent-ssh/authorized_public_keys` file *before* running the terraform scripts.
  - The instance metadata should also have `enable-oslogin=false`, because OS Login and SSH manual keys cannot be used at the same time.
  - The GCE instance must have a user such as `jenkins` or any other username that is also configured on the Maser side ad the user initiating the connection.

You can always deploy additional agents if you need to.

#### Jenkins Master

We assume that you already have a Jenkins Master running either on-prem or in another cloud. Therefore, the Terraform module doesn't deploy a Jenkins Master.

If you don't have a Jenkins Master, you can deploy the container in `jenkins-master-onprem/` as a _test_ to get you up and running.

Since the Jenkins Master acts as an SSH client, it needs the ssh private key corresponding to the public key you copied into `jenkins-agent-ssh/authorized_keys`. We explain how to handle that in the Configuration section below.

# 2. Requirements
 - Docker
 - Terraform

# 3. Configuration

### 3.1. Create the SSH key pair
The SSH key pair is used to establish authentication between the Jenkins Master (SSH client, needs the private key) and the Agent (SSH Server, needs the public key).

You can generate these keys in any linux computer by using the `ssh-keygen` command. The important thing is to **keep the private key secure**.

Let's assume you are creating the SSH key pair in your local linux computer.

Run these commands in your terminal:
```
JENKINS_AGENT_NAME="Agent1"
PASSWD_TO_PROTECT_SSH_PRIVATE_KEY="password-to-protect-the-ssh-private-key"
mkdir ~/.ssh; cd ~/.ssh/
ssh-keygen -t rsa -m PEM -N "${PASSWD_TO_PROTECT_SSH_PRIVATE_KEY}" -C "Jenkins ${JENKINS_AGENT_NAME} key" -f jenkins${JENKINS_AGENT_NAME}_rsa
```

### 3.2. Configure the public SSH key

Run this command in your terminal:
```
cat ~/.ssh/jenkins${JENKINS_AGENT_NAME}_rsa.pub
# [The output here is a public ssh key]
```
**Copy the output above into the `jenkins-agent-ssh/authorized_keys` file provided in this repo.**

### 3.3. Build and Run the Jenkins Agent
**TODO: UPDATE THIS WHEN THE TERRAFORM MODULE IS COMPLETED**

Run these commands in your terminal:
```
cd jenkins-agent-ssh/
docker build --tag jenkins_agent-ssh_img:$TAG_NUMBER .
docker run --detach --name jenkins-agent-ssh-container-$TAG_NUMBER jenkins_agent-ssh_img:$TAG_NUMBER
cd ..
```

### 3.4. [Optional] Create a Jenkins Master

**If you already have a Jenkins Master, go to section 3.5**

As explained in the introduction, we assume that you already have a Jenkins Master running either on-prem or in another cloud. If you don't have a Jenkins Master, follow steps here to deploy `jenkins-master-onprem/` as a test to get yourself up and running.

#### 3.4.1. Configure `ENV` variables for the Jenkins Master

If you decide to use the Jenkins Master provided in `jenkins-master-onprem/`, you need to configure the `ENV` variables in `jenkins-master-onprem/Dockerfile`, because they are used in the `jcac.yam` file.

The `jcac.yam` file is also called "_Jenkins Configuration As Code_".
 
`jcac.yam` contains all the configuration that otherwise would need to be manually entered in the web UI of the Jenkins Master. `jcac.yam` should not be confused with the `Jenkinsfile`.

`Jenkinsfile` defines the code integration (CI) pipeline and that lives in your Git repository, alongside with your code.

Configure the following variables in `jenkins-master-onprem/Dockerfile`:
```
# SSH Jenkins Agent which we want to connect to
JENKINS_AGENT_NAME
JENKINS_AGENT_IP_ADDR
JENKINS_AGENT_USER_HOME_DIR
JENKINS_AGENT_REMOTE_DIR

# WEB UI LOGIN: Jenkins Master Admin
JENKINS_WEB_UI_ADMIN_USER
JENKINS_WEB_UI_ADMIN_PASSWD
JENKINS_WEB_UI_ADMIN_EMAIL

# PIPELINE Variables: Github repository we want Jenkins to conect to
GITHUB_USERNAME
GITHUB_TOKEN
GITHUB_REPO_NAME

```

#### 3.4.2. Build and Run the Jenkins Master 
Run these commands in your terminal from `jenkins-master-onprem/` directory:
 ```
TAG_NUMBER="0.1"
docker build --tag jenkins_master_img:$TAG_NUMBER .
docker run --publish 8080:8080 --detach --name jenkins-master-container jenkins_master_img:$TAG_NUMBER 
```

### 3.5. Configure the SSH private key

Tu continue here, you must have a Jenkins Master running. If you don't, you can implement the sample Master as indicated in section 3.4.

#### 3.5.1. Copy the private SSH key
 Run this command in your terminal:
 ```
 cat ~/.ssh/jenkins${JENKINS_AGENT_NAME}_rsa
 ```

The output from the command above is a private ssh key that looks like this:
```
 # -----BEGIN RSA PRIVATE KEY-----
 # .
 # .
 # . Copy the entire Private key,
 # . including BEGIN and END lines
 # .
 # .
 # -----END RSA PRIVATE KEY-----
```

#### 3.5.2. Paste the private SSH key in your Jenkins Master's Web UI
Follow these steps from your Jenkins Master's Web UI:

```
1 - Log in to the Web UI of your Jenkins Master
2 - Click on "Credentials"
3 - Find and click on the credential "ssh_private_key_to_connect_to_<Agent-Name>"
4 - Click on "Update"
5 - Click on "Replace"
6 - Paste the private key in the textbox "Enter New Secret Below"
```

### 3.6. Confirm Jenkins Master is connected to the SSH Agent
Follow these steps from your Jenkins Master's Web UI:

```
1 - Log in to the Web UI of your Jenkins Master
2 - Confirm the jenkins-ssh-agent-<Agent-Name> is "Idle" Under "Build Executor Status"
3 - You can also click on the Agent link and then on "Log" to se more details
```

