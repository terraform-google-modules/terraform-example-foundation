# Glossary

Defined terms in the documentation for Terraform Example Foundation are capitalized and have
specific meaning within the domain of knowledge.

## Terraform Service Account

The email for the privileged service account created in the seed project of the step 0-bootstrap.
This service account is used to run Terraform by Cloud Build and Jenkins. When using Jenkins, the service account of the Jenkins Agent uses impersonation over this Terraform Service Account.

## Seed Project

Seed Project created in the 0-bootstrap step. It is the project where the Terraform Service Account (`terraform_service_account`) is created and hosts the GCS bucket used to store Terraform state of each environment in subsequent phases.

## Foundation CI/CD Pipeline

A project created in step 0-bootstrap to manage infrastructure **within the organization**.
The pipeline can use either **Cloud Build** or **Jenkins** depending or your context and Terraform is executed using the seed project service account.
Also known as the CI/CD project.
It is located under folder `bootstrap`.

## App Infra Pipeline

A project created in step 4-projects to host a Cloud Build pipeline configured to manage application infrastructure **within projects**.
A separate pipeline exists for each of the business units and it can be configured to use a service account that has limited permissions to deploy into certain projects created in 4-projects.
They are located under folder `common`.

## Terraform Remote State Data Source

A Terraform Data Source that retrieves output values from a remote [Backend Configuration](https://www.terraform.io/language/settings/backends/configuration).
In the Terraform Example Foundation context, it reads output values from previous steps like `0-bootstrap` so that users don't need to provide again values given as inputs on previous steps or find the values/attributes of resources created in previous steps.
