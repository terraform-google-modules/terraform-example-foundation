This guide is designed for **AI coding assistants, LLMs, and autonomous agents** contributing to the `terraform-example-foundation` repository. It outlines the architectural mental model, directory structure, development workflows, security guardrails, and verification procedures required to generate high-quality, production-ready contributions.

---

## 1. Repository Identity & Mission

This repository implements the Google Cloud Platform (GCP) **Enterprise Foundations blueprint** (`terraform-example-foundation`). It provides a secure baseline to build and customize a Google Cloud foundation using Cloud Foundation Toolkit (CFT) Terraform modules.

*   **Automate Organization and Environment Provisioning**: Provisions the GCP resource hierarchy (folders and projects) across `development`, `nonproduction`, and `production` environments (with support for `production_only_deploy`).
*   **Enforce Separation of Duties**: Isolates permissions across stages using dedicated, least-privileged Service Accounts for platform, security, network, and application operations.
*   **Enforce Security Guardrails by Default**: Implements organization policies, centralized audit logging (Cloud Storage, Pub/Sub, and log bucket sinks), SCC notifications, Cloud KMS, and Secret Manager.
*   **Configure Enterprise Networking**: Deploys Shared VPC or Hub-and-Spoke networks, subnets, hierarchical firewall policies, Private Google Access, Cloud NAT, Cloud DNS, and Network Connectivity Center (NCC).
*   **Automate CI/CD for Subsequent Stages**: Provisions CI/CD pipelines in `0-bootstrap` to automate the deployment of stages `1-org` through `5-app-infra` via pull requests (`plan`) and environment branch merges (`apply`), supporting Cloud Build, GitHub Actions, GitLab CI, and Terraform Cloud.

---

## 2. Architecture & Stage Execution Model

When reasoning about this codebase, agents must maintain a clear mental model of the progressive 6-stage lifecycle:

```
[0-bootstrap] ──> [1-org] ──> [2-environments] ──> [3-networks] ──> [4-projects] ──> [5-app-infra]
```

| Stage | Path / Module | Responsibility & Scope | Target Audience |
| :--- | :--- | :--- | :--- |
| **0 - Bootstrap** | `0-bootstrap/`<br>`0-bootstrap/modules/` | Seed project (`prj-b-seed`), Terraform state buckets, per-stage Service Accounts, and initial CI/CD pipeline infrastructure (`prj-b-cicd`) supporting Cloud Build, GitHub Actions, GitLab CI, or Terraform Cloud. | Platform Admin |
| **1 - Org** | `1-org/envs/shared/`<br>`1-org/modules/` | Top-level folders (`fldr-common`, `fldr-network`), organization policies, centralized audit logging (`prj-c-logging`), billing export (`prj-c-billing-export`), SCC notifications (`prj-c-scc`), Cloud Asset Inventory monitoring (`cai-monitoring`), global KMS/Secrets (`prj-c-kms`, `prj-c-secrets`), DNS hub (`prj-net-dns`), Interconnect host project (`prj-net-interconnect`), and network host projects (`prj-*-svpc`, `prj-net-hub-svpc`). | Cloud Security / Platform Admin |
| **2 - Environments** | `2-environments/envs/`<br>`2-environments/modules/` | Environment folders (`fldr-development`, `fldr-nonproduction`, `fldr-production`) and shared per-environment services (`prj-{d,n,p}-kms`, `prj-{d,n,p}-secrets`). | Platform Admin |
| **3 - Networks** | `3-networks-svpc/`<br>`3-networks-hub-and-spoke/` | Shared VPCs per environment, subnets with secondary ranges (GKE-ready), hierarchical firewall policies (IAP, health checks, Windows KMS), Cloud NAT, Private Service Access (Cloud SQL/AlloyDB), Cloud DNS, on-premises Interconnect (Dedicated or Partner), Cross-Cloud Interconnect (Dedicated or Partner), and HA-VPN (Standard Shared VPC or Hub-and-Spoke). | Network Admin |
| **4 - Projects** | `4-projects/business_unit_1/`<br>`4-projects/modules/` | Business Unit folders (`bu1`, `bu2`), service projects attached to Shared VPCs (`sample-svpc`, `sample-peering`, `sample-floating`), and dedicated application infra CI/CD pipelines (`prj-c-bu*-infra-pipeline`). | Platform Admin / Team Lead |
| **5 - App Infra** | `5-app-infra/business_unit_1/`<br>`5-app-infra/modules/` | Workload backing resources & sample compute instances (e.g., Compute Engine VM instance or Confidential Space) deployed through the stage 4 application infra pipeline. | Application Developer |

---

## 3. Directory Layout & Key Lookup
```
terraform-example-foundation/
├── 0-bootstrap/                  # Stage 0: Seed (tfstate, SAs) & CI/CD pipeline infrastructure
│   ├── modules/                  # Modules: cb-private-pool, gitlab-oidc, parent-iam-member, parent-iam-remove-role, tfc-agent-gke
│   └── scripts/                  # Scripts: choose_build_type.sh, git_create_branches_helper.sh, push-to-repo.sh
├── 1-org/                        # Stage 1: Org policies, fldr-common, centralized logs, SCC, KMS, Secrets
│   ├── envs/shared/              # Shared configuration for organization-level resources
│   └── modules/                  # Modules: centralized-logging, network, service_control, cai-monitoring
├── 2-environments/               # Stage 2: Environment folders & per-environment KMS/Secrets
│   ├── envs/                     # Environments: development, nonproduction, production
│   └── modules/env_baseline/     # Shared environment baseline module
├── 3-networks-svpc/              # Stage 3 (Standard): Shared VPC topology, firewall, NAT, DNS, IAP
│   ├── envs/                     # Environments: shared, development, nonproduction, production
│   └── modules/                  # Modules: base_env, hierarchical_firewall_policy, nat, routers, dedicated_interconnect, partner_interconnect, cross_dedicated_interconnect, cross_partner_interconnect, vpn-ha
├── 3-networks-hub-and-spoke/     # Stage 3 (Hub-and-Spoke): NCC-based hub-and-spoke network topology
│   ├── envs/                     # Environments: shared, development, nonproduction, production
│   └── modules/                  # Modules matching 3-networks-svpc with NCC routing
├── 4-projects/                   # Stage 4: Business Units, Service Projects attached to Shared VPC, App CI/CD
│   ├── business_unit_1/          # BU1 environment deployments (shared, development, nonproduction, production)
│   └── modules/                  # Modules: base_env, infra_pipelines, single_project
├── 5-app-infra/                  # Stage 5: Sample workload deployment (Compute Engine / Confidential Space)
│   ├── business_unit_1/          # Workload deployment per environment
│   └── modules/                  # Modules: env_base, confidential_space
├── helpers/                      # Auxiliary developer and operator tools
│   └── foundation-deployer/      # Go CLI to automate and sequence multi-stage deployments & teardown
├── build/                        # CI/CD pipelines & automation scripts (tf-wrapper.sh, cloudbuild, github, gitlab)
├── scripts/                      # Prerequisites validation and helper scripts (validate-requirements.sh)
├── test/                         # Quality assurance and testing harness
│   ├── setup/                    # Terraform harness provisioning CI test environment
│   └── integration/              # Blueprint-test integration tests (bootstrap, org, envs, networks, projects, app-infra)
└── docs/                         # Architecture guides, policy rules, glossary, and troubleshooting
```

---

## 4. Agent Working Rules & Coding Conventions
When generating or updating code, AI agents MUST strictly adhere to the following standards:

### 4.1. Terraform Conventions
*   **Formatting**: Always run `terraform fmt -recursive` on modified Terraform directories.
*   **Explicit Types & Descriptions**: Every `variable` and `output` must have an explicit `type` and an informative `description`.
*   **No Hardcoded Resource IDs**: Never hardcode Project IDs, VPC names, or Service Account emails. Parameterize them via variables or derive them from data sources/outputs.
*   **Documentation Hooks**: Do not edit the content inside `<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->` blocks manually. These are generated by `terraform-docs` (via `make generate_docs` / `make docker_generate_docs`).
*   **Version Pinning**: Maintain consistent provider version constraints (`>= 5.0` for `google` / `google-beta`, `>= 1.5.7` for Terraform core).

### 4.2. Security & IAM Guardrails (Strict Enforcement)
*   **Principle of Least Privilege**: Never assign broad administrative roles (e.g., `roles/owner`, `roles/editor`, `roles/resourcemanager.organizationAdmin`, `roles/accesscontextmanager.policyAdmin`). Always prefer granular or read-only roles (e.g., `roles/resourcemanager.organizationViewer`, `roles/accesscontextmanager.policyReader`).
*   **No Plaintext Secrets**: Store all sensitive tokens, passwords, and private keys in Secret Manager. Reference secrets via secret accessors or Cloud KMS keys.
*   **Private Connectivity**:
    *   Compute resources must not have external IP addresses. Access is routed via Identity-Aware Proxy (IAP) TCP forwarding.
    *   Google APIs must communicate over Private Google Access (`restricted.googleapis.com` or `private.googleapis.com`).
    *   Outbound internet access is restricted through Cloud NAT with logging.
*   **VPC Service Controls (VPC-SC)**: Infrastructure modules and CI/CD pipelines must support execution inside VPC-SC perimeters.
*   **Isolated CI/CD**: Cloud Build triggers must run inside private worker pools connected to dedicated VPCs with least-privileged service accounts per stage.

### 4.3. Go & Integration Test Conventions (`test/integration/`)
*   **Framework**: Integration tests are written in Go using CFT [blueprint-test](https://github.com/GoogleCloudPlatform/cloud-foundation-toolkit/tree/main/infra/blueprint-test).
*   **Formatting**: Format all Go files with `gofmt -s -w <file.go>`.
*   **Test Isolation**: Tests must create unique resource names or utilize prefixes to prevent collision during concurrent CI test runs.

### 4.4. Branching & Environment Promotion Conventions
*   **Sequential Promotion**: Target feature and bugfix PRs to `development`; promote changes sequentially to `nonproduction` and `production`.
*   **Shared Environment Rule**: Any modifications to `envs/shared/` resources are applied strictly upon merge into the `production` branch.
*   **Single-Environment Compatibility**: Ensure all new or modified stage modules maintain zero-drift compatibility when `production_only_deploy = true`.

---

## 5. Step-by-Step Contribution Workflows for Agents

### Workflow A: Adding or Modifying a Terraform Module (`modules/` or stage submodules)
1. **Implement Terraform Changes**: Update or create resources in stage module directories.
2. **Expose Variables & Outputs**: Ensure all inputs and outputs in `variables.tf` and `outputs.tf` have type constraints and descriptions.
3. **Format Code**: Run `terraform fmt` in the module directory.
4. **Update Documentation**: Update module `README.md` and execute `make docker_generate_docs`.
5. **Add Integration Tests**: Add or update the corresponding Go integration test suite under `test/integration/`.

### Workflow B: Updating IAM Permissions & Security Policies
1. **Identify Required Role**: Check the minimal required IAM permissions for the specific API calls.
2. **Avoid Wildcard / Admin Roles**: Replace any overly permissive roles with scoped alternatives.
3. **Test with Harness**: Verify that the changes pass integration tests in `test/setup/` or `test/integration/`.

### Workflow C: Code Linting & Plan Validation
1. **Lint Code**: Execute `make docker_test_lint` to validate Terraform, Shell, YAML, and Go formatting and syntax.
2. **Validate Plans & Test Integration**: Run stage integration tests (`test/integration/`) to verify generated Terraform plans and ensure deployments pass without execution errors.

---

## 6. Testing & Quality Assurance Playbook

Agents should use the following tools and commands to validate changes:

### 1. Code Formatting
```bash
# Format Terraform code across the entire repository
terraform fmt -recursive

# Format Go code
gofmt -s -w helpers/ test/
```

### 2. Linting & Validation (via Docker Developer Tools)
```bash
# Execute lint checks (Terraform, Shell, YAML, Go)
make docker_test_lint

# Generate module documentation tables
make docker_generate_docs
```

### 3. Running Integration Tests Locally

Integration tests require a test harness provisioned via `test/setup/`.

#### Step 1: Configure Test Variables (`test/setup/terraform.tfvars`)
Create a `terraform.tfvars` file inside `test/setup/` with the required parameters:
```hcl
org_id                   = "012345678901"
folder_id                = "123456789012"
billing_account          = "XXXXXX-YYYYYY-ZZZZZZ"
group_email              = "gcp-admins@example.com"
domain_to_allow          = "example.com"
example_foundations_mode = "default" # or "production_only_deploy"
```

#### Step 2: Provision Harness & Run Tests
```bash
# 1. Provision test harness environment
cd test/setup
terraform init && terraform apply -auto-approve

# 2. Run stage integration tests sequentially
cd ../integration

# Control lifecycle execution via RUN_STAGE (e.g., init,apply,verify,teardown)
export RUN_STAGE="init,apply,verify,teardown"

go test -v -run TestBootstrap ./bootstrap -timeout 60m
go test -v -run TestOrg ./org -timeout 60m
go test -v -run TestEnvs ./envs -timeout 60m
go test -v -run TestNetworks ./networks -timeout 60m
go test -v -run TestProjects ./projects -timeout 60m
go test -v -run TestAppInfra ./app-infra -timeout 60m

# 3. Clean up test harness environment
cd ../setup
terraform destroy -auto-approve
```

> [!NOTE]
> **Sequential Execution & Teardown Order**: When executing stages without immediate destruction (e.g., `RUN_STAGE="init,apply,verify"`), execute stage tests in progressive order (`0-bootstrap` → `5-app-infra`). For stage teardown (`RUN_STAGE="teardown"`), execute tests in reverse order (`5-app-infra` → `0-bootstrap`).

---

## 7. Pre-Commit Verification Checklist for Agents
Before completing any task or proposing changes, verify that:

- [ ] `terraform fmt -recursive` runs cleanly without formatting errors.
- [ ] All new variables have explicit `type` definitions and meaningful `description` strings.
- [ ] No hardcoded GCP project IDs, credentials, or sensitive secrets exist in `.tf`, `.tfvars`, or `.yaml` files.
- [ ] IAM roles strictly follow the Principle of Least Privilege.
- [ ] Any modified module has its documentation updated (`README.md` inputs/outputs).
- [ ] Go test files follow `gofmt` style and compile without errors (`go vet ./...`).
- [ ] Commit descriptions follow the Conventional Commits standard (`feat:`, `fix:`, `feat!:` , or `fix!:` summary line + explanatory "Why" body).
- [ ] Documentation updates comply with the [Google Developer Documentation Style Guide](https://developers.google.com/style).

---

## 8. Standards & Reference Links
*   **Documentation Style Guide**: [Google Developer Documentation Style Guide](https://developers.google.com/style)
*   **CL / Commit Guidelines**: [Google Engineering Practices on Writing Good CL Descriptions](https://google.github.io/eng-practices/review/developer/cl-descriptions.html)
*   **Code Review Speed**: [Google Engineering Practices on Code Review Speed](https://google.github.io/eng-practices/review/reviewer/speed.html)
*   **Enterprise Foundation Blueprint**: [Google Cloud Documentation](https://cloud.google.com/architecture/security-foundations)
*   **CFT Blueprint Test Framework**: [CFT blueprint-test](https://github.com/GoogleCloudPlatform/cloud-foundation-toolkit/tree/main/infra/blueprint-test) (and [Go package documentation](https://pkg.go.dev/github.com/GoogleCloudPlatform/cloud-foundation-toolkit/infra/blueprint-test))
*   **Troubleshooting Guide**: Consult [`docs/TROUBLESHOOTING.md`](./docs/TROUBLESHOOTING.md) for known edge cases and resolutions.
