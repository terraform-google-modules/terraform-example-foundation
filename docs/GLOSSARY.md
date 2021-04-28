# Glossary

Defined terms in the documentation for Terraform Example Foundation are capitalized and have
specific meaning within the domain of knowledge.

## Terraform Service Account

The email for privileged service account created in the seed project of the step 0-bootstrap.
This service account is used to run Terraform by Cloud Build and Jenkins using service account impersonation.

## Seed Project

Project created in step 0-bootstrap. Is the project where the Terraform Service Account is create and host the terraform state bucket used to preserve the state snapshots of the Terraform execution of each environment in each step.

## Foundation Pipeline

A project create in step 0-bootstrap to manage infrastructure **within the organization**.
The pipeline can use **Cloud Build** or **Jenkins** depending or your context.
Also know as the CI/CD project.
It is located under folder `bootstrap`.

## App Infra Pipeline

Projects created in step 4-projects to host a Cloud Build pipeline configured to manage infrastructure **within projects**.
A separate one exists for each one of the business units.
They are located under folder `common`.
