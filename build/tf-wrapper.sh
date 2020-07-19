##TODO:  better error handling
##TODO:  variable for path?
##TODO:  How does this work for monorepo?
##TODO:  

#!/bin/bash
branchname=$2
policyrepo=$3

tf_validator_path="./terraform-validator-linux-amd64"

##functions
tf_apply() {
  terraform apply -input=false -auto-approve $branchname.tfplan || exit 1
}

tf_init() {
  terraform init || exit 11
}

tf_plan() {
  terraform plan -input=false -out $branchname.tfplan || exit 21
}

tf_validate() {
  if ! ${tf_validator_path} version &> /dev/null; then
    echo "terraform-validator not found!  Check path or visit"
    echo "https://github.com/forseti-security/policy-library/blob/master/docs/user_guide.md#how-to-use-terraform-validator"
  else
    terraform show -json $branchname.tfplan > $branchname.json || exit 32
    terraform-validator-linux-amd64 validate $branchname.json --policy-path=${policyrepo} || exit 33
  fi
}

##main
case "$1" in
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
  
  validate )
    echo "*************** TERRAFORM VALIDATE ******************"
    echo "      At environment: ${branchname} "
    echo "      Using policy from: ${policyrepo} "
    echo "****************************************************"
    
    cd ./envs/$branchname
    
    if [ ! -d ".terraform" ]; then 
      tf_init
    fi
    
    if [ ! -f "${branchname}.tfplan" ]; then
      tf_plan
    fi
    
    tf_validate
    ;;
  * )
    echo "unknown option: ${1}"
    exit 99
    ;;
esac
