# Frequently Asked Questions

## Why am I encountering a low quota with projects created via Terraform Example Foundation?

When you deploy the Terraform Example Foundation steps with the Service Account created in step 0-bootstrap,
the project quota will be based on the reputation of your service account rather than your user identity.
In many cases, this quota is initially low.

We recommend that your request 50 additional projects for the service account, `terraform_service_account`, created in step 0-bootstrap.
you can use the [Request Project Quota Increase](https://support.google.com/code/contact/project_quota_increase) form to request the quota increase.
In the support form, for **Email addresses that will be used to create projects**, use the `terraform_service_account` address that's created in the organization bootstrap module.
If you see other quota errors, see the [Quota documentation](https://cloud.google.com/docs/quota).
