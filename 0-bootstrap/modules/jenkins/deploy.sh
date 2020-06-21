# shellcheck disable=SC2155
export DIR="$( cd "$( dirname "${BASH_SOURCE[0]}" )" >/dev/null 2>&1 && pwd )"

#Test SSH in the AGENT:
# sudo /usr/sbin/sshd -ddd -p 2222

#Test SSH in the MASTER:
# eval "$(ssh-agent -s)" && ssh-add /home/jenkins/.ssh/jenkinsAgent1_rsa && ssh-add -l
# ssh -vvv -i /home/jenkins/.ssh/jenkinsAgent1_rsa.pub jenkins@192.168.9.2 -p 2222


#printf "\n--------------------------------------\n"
#echo "1 - WORKING IN THE LOCAL HOST"

#export JENKINS_AGENT_NAME="Agent2"
#export SSH_LOCAL_CONFIG_DIR="$HOME/.ssh"
#export JENKINS_SSH_PRIVATE_KEY_PASSWD="aaaaa"
#ssh-keygen -t rsa -m PEM -N "${JENKINS_SSH_PRIVATE_KEY_PASSWD}" -C "Jenkins ${JENKINS_AGENT_NAME} key" -f "${SSH_LOCAL_CONFIG_DIR}"/jenkins${JENKINS_AGENT_NAME}_rsa
#ssh-keygen -t rsa -m PEM -C "Jenkins ${JENKINS_AGENT_NAME} key" -f "${SSH_LOCAL_CONFIG_DIR}"/jenkins${JENKINS_AGENT_NAME}_rsa
# Keep the private key in the Master
# ## Generate the SSH key that Jenkins Master (SSH client) will need to connect to this Agent
#export JENKINS_SSH_PRIVATE_KEY_PASSWD="password-to-protect-the-ssh-private-key"

#echo "Creating $SSH_LOCAL_CONFIG_DIR directory"
#mkdir "$SSH_LOCAL_CONFIG_DIR"
#
#echo "Generating public and private SSH keys"
#ssh-keygen -t rsa -m PEM -N "${JENKINS_SSH_PRIVATE_KEY_PASSWD}" -C "Jenkins ${JENKINS_AGENT_NAME} key" -f "${SSH_LOCAL_CONFIG_DIR}"/jenkins${JENKINS_AGENT_NAME}_rsa

printf "\n\n--------------------------------------\n"
printf "2 - WORKING WITH THE JENKINS AGENT\n"
export TAG_NUMBER="0.1"

#printf "Add the public SSH key to the list of keys authorized to connect to the Agent\n"
#cat "${SSH_LOCAL_CONFIG_DIR}"/jenkins${JENKINS_AGENT_NAME}_rsa.pub > "${DIR}/jenkins-agent-ssh/authorized_public_keys"

printf "2.1 - Stop and delete the Agent container if it exist"
docker container stop jenkins-agent-ssh-container-$TAG_NUMBER
docker container rm jenkins-agent-ssh-container-$TAG_NUMBER

printf "2.2 - now build & run the Agent container\n"
cd "$DIR/jenkins-agent-ssh" || exit
docker build --tag jenkins-agent-ssh-img:$TAG_NUMBER .
#docker run --publish 2222:22     --detach --name jenkins-agent-ssh-container-$TAG_NUMBER jenkins_agent-ssh_img:$TAG_NUMBER
docker run --detach --name jenkins-agent-ssh-container-$TAG_NUMBER jenkins-agent-ssh-img:$TAG_NUMBER

# *************************************************************************
## In GCP:
#HOSTNAME="eu.gcr.io"
#PROJECT_ID="terraform-tests-277515"
#SOURCE_IMAGE="jenkins-agent-ssh-img:0.1"
#
#GCR_IMAGE=$HOSTNAME/$PROJECT_ID/$SOURCE_IMAGE
#
#JENKINS_GCE_INSTANCE_NAME="jenkins-agent-ssh-gce"
#
## Building Jenkins Image and pushing it to GCR
#docker build --tag $SOURCE_IMAGE .
#docker tag $SOURCE_IMAGE $GCR_IMAGE
#docker push $GCR_IMAGE
#
## Deploying a container on a new VM instance
#gcloud compute instances create-with-container $JENKINS_GCE_INSTANCE_NAME \
#     --container-image $GCR_IMAGE \
#     --project $PROJECT_ID
#
#
#gcloud compute ssh $JENKINS_GCE_INSTANCE_NAME --container klt-jenkins-agent-ssh-gce-xxsm \
#--project $PROJECT_ID --zone "us-central1-f"
#
## sudo docker exec -ti klt-jenkins-agent-ssh-gce-xxsm /bin/bash
# *************************************************************************

printf "\n\n--------------------------------------\n"
printf "3 - WORKING WITH THE JENKINS MASTER\n"
#cd ../ || exit
## Copy the private to the Master web UI
#cat "${SSH_LOCAL_CONFIG_DIR}"/jenkins${JENKINS_AGENT_NAME}_rsa > "${DIR}/jenkins-master/jenkins${JENKINS_AGENT_NAME}_rsa"
#cat "${SSH_LOCAL_CONFIG_DIR}"/jenkins${JENKINS_AGENT_NAME}_rsa.pub > "${DIR}/jenkins-master/jenkins${JENKINS_AGENT_NAME}_rsa.pub"

printf "3.1 - Stop and delete the Master container if it exist\n"
docker container stop jenkins-master-container-$TAG_NUMBER
docker container rm jenkins-master-container-$TAG_NUMBER

printf "2.2 - now build & run the Master container\n"
cd "$DIR/jenkins-master" || exit
docker build --tag jenkins_master_img:$TAG_NUMBER .
docker run --publish 8080:8080 --detach --name jenkins-master-container-$TAG_NUMBER jenkins_master_img:$TAG_NUMBER

#docker exec -ti jenkins-master-container-${TAG_NUMBER} /bin/bash
#ssh jenkins@192.168.9.2 -i ~/.ssh/jenkinsAgent1_rsa

##cat ~/.ssh/jenkins${JENKINS_AGENT_NAME}_rsa.pub
##export SSH_PRIVATE_KEY=$`(cat ~/.ssh/jenkins${JENKINS_AGENT_NAME}_rsa | openssl base64 | tr -d '\n')`
##echo $SSH_PRIVATE_KEY | openssl base64 -A -d
#
