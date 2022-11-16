# Guidance for modifications of the resource hierarchy

This guide explains the instructions to change resource hierarchy during Terraform Foundation Example blueprint deployment.

The current deployment scenario of Terraform Foundation Example blueprint considers a flat resource hierarchy where all folders are at the same level and have one folder for each environment. Here is a detailed explanation of each folder:

| Folder | Description |
| --- | --- |
| bootstrap | Contains the seed and CI/CD projects that are used to deploy foundation components. |
| common | Contains projects with cloud resources used by the organization. |
| production | Environment folder that contains projects with cloud resources that have been promoted into production. |
| non-production | Environment folder that contains a replica of the production environment to let you test workloads before you put them into production. |
| development | Environment folder that is used as a development and sandbox environment. |

This document covers a scenario where you can have two or more levels of folders, with an environment-centric focus: `environments -> ... -> business units`.

| Current Hierarchy | Changed Hierarchy |
| --- | --- |
| <pre>example-organization/<br>├── fldr-bootstrap<br>├── fldr-common<br>├── <b>fldr-development *</b><br>├── <b>fldr-non-production *</b><br>└── <b>fldr-production *</b><br></pre> | <pre>example-organization/<br>├── fldr-bootstrap<br>├── fldr-common<br>├── <b>fldr-development *</b><br>│   ├── finance<br>│   └── retail<br>├── <b>fldr-non-production *</b><br>│   ├── finance<br>│   └── retail<br>└── <b>fldr-production *</b><br>    ├── finance<br>    └── retail<br></pre> |

## Code Changes - Build Files

Review the `tf-wrapper.sh`. It is a bash script helper responsible for applying  terraform configurations for Terraform Foundation Example blueprint. The `tf-wrapper.sh` script works based on the current branch (see [Branching strategy](../README.md#branching-strategy)) and searches for a folder in the source code where name matches the current branch name. When it finds a folder it applies the terraform configurations. These changes below will make `tf-wrapper.sh` capable of searching deeper for matching folders and complying with your source code folder hierarchy.

1. Create a new variable `maxdepth` to set how many source folder levels should be searched for terraform configurations.

    ```text
    ...
    tmp_plan="${base_dir}/tmp_plan"
    environments_regex="^(development|non-production|production|shared)$"

    # Create maxdepth variable
    maxdepth=2  #🟢 Must be configured based in your directory design

    #🟢 Create component temp variables
    current_component=""
    old_component=""

    ## Terraform apply for single environment.
    tf_apply() {
    ...
    ```

1. Change find commands to use maxdepth variable on all terraform commands. Make sure you do the same changes in functions: `tf_plan_validate_all` and `single_action_runner`.

    ```text
    tf_plan_validate_all() {
    local env
    ...
    #🟢 Set maxdepth in find command -------------- 🟢
    find "$component_path" -mindepth 1 -maxdepth $maxdepth -type d | while read -r env_path ; do
        env="$(basename "$env_path")"
    ```

1. Add handling component variable and call to new function `check_env_path_folder`.

    ```text
    ...
    env="$(basename "$env_path")"

    old_component=$component #🟢 Holds component value before call check_env_path_folder

    #🟢 Calls check_env_path_folder to get fixed component value
    check_env_path_folder "$env_path" "$base_dir" "$component" "$env"

    component=$current_component #🟢 Get fixed component value
    ...
    if [[ "$env" =~ $environments_regex ]] ; then
    ```

1. Fix warning message for doesn't match directories.

    ```text
        ...
        tf_plan "$env_path" "$env" "$component"
        tf_validate "$env_path" "$env" "$policysource" "$component"
      else
        #🟢 Replace dash (-) for slash (/) in component to fix warning message
        echo "$(echo ${component} | sed -r 's/-/\//g' )/$env doesn't match $environments_regex; skipping"
      fi

      component=$old_component #🟢 Assign old component value before next while-loop iteration
    done
    ```

1. Do the same changes in `single_action_runner` function.

    ```text
    single_action_runner() {
    local env
    ...
    #🟢 Set maxdepth in find command -------------- 🟢
    find "$component_path" -mindepth 1 -maxdepth $maxdepth -type d | sort -r | while read -r env_path ; do
        env="$(basename "$env_path")"

        old_component=$component #🟢 Holds component value before call check_env_path_folder

        #🟢 Calls check_env_path_folder to get fixed component value
        check_env_path_folder "$env_path" "$base_dir" "$component" "$env"

        component=$current_component #🟢 Get fixed component value
    ...
    ```

1. Fix warning message for doesn't match directories.

    ```text
        esac
      else
        #🟢 Replace dash (-) for slash (/) in component to fix warning message
        echo "$(echo ${component} | sed -r 's/-/\//g' )/${env} doesn't match ${branch}; skipping"
      fi

      component=$old_component #🟢 Assign old component value before next while-loop iteration
    done
    ```

1. Create a new function `check_env_path_folder`.

    ```text
    ...
    #🟢 New check_env_path_folder function

    ## Fix component name to be different for each environment. It is used as tf-plan file name
    check_env_path_folder() {
    local lenv_path=$1
    local lbase_dir=$2
    local lcomponent=$3
    local lenv=$4

    if [[ "$lenv_path" =~ ^($lbase_dir)/(.+)/$lenv ]] ; then
        # The ${BASH_REMATCH[2]} means the second group in regex expression
        # This group is the folders between base dir and env
        # This value guarantees that tf-plan file name will be unique for each environment
        current_component=$(echo ${BASH_REMATCH[2]} | sed -r 's/\//-/g')
    else
        current_component=$lcomponent
    fi
    }

    #🟢 End of New check_env_path_folder function

    case "$action" in
    init|plan|apply|show|validate )
    ...
    ```

## Code Changes - Terraform Files

<pre>
example-organization/
├── bootstrap
├── common
├── <b>development *</b>
│   ├── finance
│   └── retail
├── <b>non-production *</b>
│   ├── finance
│   └── retail
└── <b>production *</b>
    ├── finance
    └── retail
</pre>

*Example 1 - An example of Terraform Foundation Example with hierarchy changed*

### Step 2-environments

1. Create the folder hierarchy for the business units in each environment.

    Example:

    2-environments/envs/development/main.tf

    ```text
    module "env" {
        source = "../../modules/env_baseline"

        env = "development"
        ...
    }

    /* 🟢 Folder hierarchy creation */
    resource "google_folder" "finance" {
        display_name = "finance"
        parent       = module.env.env_folder
    }

    resource "google_folder" "retail" {
        display_name = "retail"
        parent       = module.env.env_folder
    }
    ```

1. Create an output with a flat representation of the new hierarchy in each environment. It will be used in the next steps to host GCP projects.

    *Table 1 - Example output for Example 1 resource hierarchy*

    | Folder Path | Folder Id |
    | --- | --- |
    | development | folders/0000000 |
    | development/finance | folders/11111111 |
    | development/retail | folders/2222222 |

    *Table 2 - Example output for resource hierarchy with more levels*

    | Folder Path | Folder Id |
    | --- | --- |
    | development | folders/0000000 |
    | development/us | folders/11111111 |
    | development/us/finance | folders/2222222 |
    | development/us/retail | folders/3333333 |
    | development/europe | folders/4444444 |
    | development/europe/finance | folders/5555555 |
    | development/europe/retail | folders/7777777 |

    Example:

    2-environments/envs/development/outputs.tf

    ```text
    ...
    /* 🟢 Folder hierarchy output */
    output "folder_hierarchy" {
        value = {
        "development" = module.env.env_folder
        "development/finance" = google_folder.finance.name
        "development/retail" = google_folder.retail.name
        }
    }
    ```

### Step 4-projects

1. Change the base_env module to receive the new folder key (e.g. development/retail) in the hierarchy map from step 2-environments.
1. This folder key should be used to get the folder where projects should be created.
    Example:

    4-projects/modules/base_env/variables.tf

    ```text
    ...
    /* 🟢 Folder Key variable */
    variable "folder_hierarchy_key" {
        description = "Key of the folder hierarchy map to get the folder where projects should be created."
        type = string
        default = ""
    }
    ...
    ```

    4-projects/modules/base_env/main.tf

    ```text
    locals {
        ...
        /* 🟢 Get new folder */
        env_folder_name = lookup(
        data.terraform_remote_state.environments_env.outputs.folder_hierarchy, var.folder_hierarchy_key
        , data.terraform_remote_state.environments_env.outputs.env_folder)
        ...
    }
    ...
    ```

1. Create your folder hierarchy above environment folders (development, non-production, production). Remember to keep the environment folders as leaves (latest level) in the source code folder hierarchy because this is the way `tf-wrapper.sh` - that is the bash script helper - works to apply terraform configurations.
1. For this example, just rename folders business_unit_1 and business_unit_2 to your Business Units names, i.e: finance and retail, to match the example folder hierarchy.
1. Manually duplicate your source folder hierarchy to match your needs.
1. Change backend gcs prefix for each business unit shared resources.
    Example:

    4-projects/finance/shared/backend.tf

    ```text
    ...
    terraform {
        backend "gcs" {
            bucket = "<YOUR_PROJECTS_BACKEND_STATE_BUCKET>"

            /* 🟢 Review prefix path */
            prefix = "terraform/projects/finance/shared"
        }
    }
    ```

1. Review locals and business code in Cloud Build project pipelines.
    Example:

    4-projects/finance/shared/example_infra_pipeline.tf

    ```text
    locals {
        /* 🟢 Review locals */
        repo_names = ["finance-app"]
    }
    ...

    module "app_infra_cloudbuild_project" {

        /* 🟢 Review module path */
        source = "../../modules/single_project"
        ...
        primary_contact   = "example@example.com"
        secondary_contact = "example2@example.com"

        /* 🟢 Review business code */
        business_code     = "fin"
    }
    ```

1. Change backend gcs prefix for each business unit.
    Example:

    4-projects/finance/development/backend.tf

    ```text
    ...
    terraform {
        backend "gcs" {
            bucket = "<YOUR_PROJECTS_BACKEND_STATE_BUCKET>"

            /* 🟢 Review prefix path */
            prefix = "terraform/projects/finance/development"
        }
    }
    ```

1. Review business_code and business_unit to match your new business unit names.
1. Set new folder_hierarchy_key parameter on base_env calls.

    Example:

    4-projects/finance/development/main.tf

    ```text
    module "env" {
        /* 🟢 Review module path */
        source = "../../modules/base_env"

        env                  = "development"

        /* 🟢 Review business code */
        business_code        = "fin"
        business_unit        = "finance"

        /* 🟢 Set folder key parameter */
        folder_hierarchy_key = "development/finance"
        ...
    }
    ```
