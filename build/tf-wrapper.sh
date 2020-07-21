<<<<<<< HEAD
#!/bin/bash

# Copyright 2020 Google LLC
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#      http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.

=======
##TODO:  better error handling
##TODO:  variable for path?
##TODO:  How does this work for monorepo?
##TODO:  

#!/bin/bash
>>>>>>> 80d357c6d691c986759ebe3c41d087df06b69f67
branchname=$2
policyrepo=$3

tf_validator_path="./terraform-validator-linux-amd64"

##functions
tf_apply() {
<<<<<<< HEAD
  terraform apply -input=false -auto-approve "${branchname}.tfplan" || exit 1
=======
  terraform apply -input=false -auto-approve $branchname.tfplan || exit 1
>>>>>>> 80d357c6d691c986759ebe3c41d087df06b69f67
}

tf_init() {
  terraform init || exit 11
}

tf_plan() {
<<<<<<< HEAD
  terraform plan -input=false -out "${branchname}.tfplan" || exit 21
=======
  terraform plan -input=false -out $branchname.tfplan || exit 21
>>>>>>> 80d357c6d691c986759ebe3c41d087df06b69f67
}

tf_validate() {
  if ! ${tf_validator_path} version &> /dev/null; then
    echo "terraform-validator not found!  Check path or visit"
    echo "https://github.com/forseti-security/policy-library/blob/master/docs/user_guide.md#how-to-use-terraform-validator"
  else
<<<<<<< HEAD
    terraform show -json "${branchname}.tfplan" > "${branchname}.json" || exit 32
    terraform-validator-linux-amd64 validate "${branchname}.json" --policy-path="${policyrepo}" || exit 33
=======
    terraform show -json $branchname.tfplan > $branchname.json || exit 32
    terraform-validator-linux-amd64 validate $branchname.json --policy-path=${policyrepo} || exit 33
>>>>>>> 80d357c6d691c986759ebe3c41d087df06b69f67
  fi
}

##main
case "$1" in
<<<<<<< HEAD
  apply )
    echo "*************** TERRAFORM APPLY *******************"
    echo "      At environment: ${branchname} "
    echo "***************************************************"

    cd "./envs/${branchname}" || exit 44

    if [ ! -d ".terraform" ]; then
      tf_init
    fi

    if [ ! -f "${branchname}.tfplan" ]; then
      tf_plan
    fi

    tf_validate

    tf_apply
    ;;

  init )
    echo "*************** TERRAFORM INIT *******************"
    echo "      At environment: ${branchname} "
    echo "**************************************************"

    cd "./envs/${branchname}" || exit 44

    tf_init
    ;;

  plan )
    echo "*************** TERRAFORM PLAN *******************"
    echo "      At environment: ${branchname} "
    echo "**************************************************"

    cd "./envs/${branchname}" || exit 44

    if [ ! -d ".terraform" ]; then
      tf_init
    fi

    tf_plan
    ;;

=======
  apply ) 
    echo "*************** TERRAFORM APPLY *******************"
    echo "      At environment: ${branchname} "
    echo "***************************************************"
    
    cd ./envs/$branchname
    
    if [ ! -d ".terraform" ]; then 
      tf_init
    fi
    
    if [ ! -f "${branchname}.tfplan" ]; then
      tf_plan
    fi
    
    tf_validate
    
    tf_apply
    ;;

  init ) 
    echo "*************** TERRAFORM INIT *******************"
    echo "      At environment: ${branchname} "
    echo "**************************************************"
    
    cd ./envs/$branchname
    
    tf_init
    ;;

  plan ) 
    echo "*************** TERRAFORM PLAN *******************"
    echo "      At environment: ${branchname} "
    echo "**************************************************"
    
    cd ./envs/$branchname
    if [ ! -d ".terraform" ]; then 
      tf_init
    fi
    
    tf_plan
    ;;
  
>>>>>>> 80d357c6d691c986759ebe3c41d087df06b69f67
  validate )
    echo "*************** TERRAFORM VALIDATE ******************"
    echo "      At environment: ${branchname} "
    echo "      Using policy from: ${policyrepo} "
    echo "****************************************************"
<<<<<<< HEAD

    cd "./envs/${branchname}" || exit 44

    if [ ! -d ".terraform" ]; then
      tf_init
    fi

    if [ ! -f "${branchname}.tfplan" ]; then
      tf_plan
    fi

=======
    
    cd ./envs/$branchname
    
    if [ ! -d ".terraform" ]; then 
      tf_init
    fi
    
    if [ ! -f "${branchname}.tfplan" ]; then
      tf_plan
    fi
    
>>>>>>> 80d357c6d691c986759ebe3c41d087df06b69f67
    tf_validate
    ;;
  * )
    echo "unknown option: ${1}"
    exit 99
    ;;
esac
