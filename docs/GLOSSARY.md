# Glossary

Defined terms in the documentation for Terraform Example Foundation are capitalized and have
specific meaning within the domain of knowledge.

## Terraform Service Account

The email for privileged service account created in the seed project of the step 0-bootstrap.
This service account is used to run Terraform by Cloud Build and Jenkins using service account impersonation.

## Seed Project

Seed Project created in the 0-bootstrap step. It is the project where the Terraform Service Account (`terraform_service_account`) is created and hosts the GCS bucket used to store Terraform state of each environment in subsequent phases.

## Foundation Pipeline

A project created in step 0-bootstrap to manage infrastructure **within the organization**.
The pipeline can use **Cloud Build** or **Jenkins** depending or your context and Terraform is executed using the seed project service account.
Also know as the CI/CD project.
It is located under folder `bootstrap`.

## App Infra Pipeline

A project created in step 4-projects to host a Cloud Build pipeline configured to manage infrastructure **within projects**.
A separate pipeline exists for each of the business units and it can be configured to use a service account that has limited permissions to deploy into certain projects created in 4-projects.
They are located under folder `common`.
