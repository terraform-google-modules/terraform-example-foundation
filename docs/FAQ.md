# Frequently Asked Questions

## Why am I encountering a low quota with projects created via Terraform Example Foundation?

When you deploy the Terraform Example Foundation with the Service Account created in step 0-bootstrap,
the project quota will be based on the reputation of your service account rather than your user identity.
In many cases, this quota is initially low.

We recommend that your request 50 additional projects for the service account, `terraform_service_account`, created in step 0-bootstrap.
You can use the [Request Project Quota Increase](https://support.google.com/code/contact/project_quota_increase) form to request the quota increase.
In the support form, for **Email addresses that will be used to create projects**, use the `terraform_service_account` address that's created in the organization bootstrap module.
If you see other quota errors, see the [Quota documentation](https://cloud.google.com/docs/quota).

## What is a "named" branch?

Certain branches in the terraform-example-foundation are considered to be
_named branches_. Pushing to a named branch causes the _apply_ command to be
run. Pushing to branches other than the named branches does not run _apply_.

* development
* nonproduction
* production

## Which Terraform commands are run when I push to a branch?

If you pushed to a _named branch_ the following commands are run: _init_, _plan_, _validate_, _apply_.

If you push to a branch that is not a named branch, only _init_, _plan_, and
_validate_ are run. The _apply_ command is not run.
