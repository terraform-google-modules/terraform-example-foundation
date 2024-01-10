# Changelog

## [4.0.0](https://github.com/terraform-google-modules/terraform-example-foundation/compare/v3.0.0...v4.0.0) (2024-01-10)


### ⚠ BREAKING CHANGES

* Add support for Log Analytics and Remove BigQuery log destination ([#1025](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1025))
* Enable CMEK for Terraform state buckets ([#1030](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1030))
* Network Refactoring ([#991](https://github.com/terraform-google-modules/terraform-example-foundation/issues/991))
* **deps:** update terraform terraform-google-modules/network/google to v7 ([#956](https://github.com/terraform-google-modules/terraform-example-foundation/issues/956))

### Features

* add assured workload example ([#934](https://github.com/terraform-google-modules/terraform-example-foundation/issues/934)) ([be568ab](https://github.com/terraform-google-modules/terraform-example-foundation/commit/be568ab4267291591a81f679bd40acb78ba1ab64))
* add instructions for deployment using GitHub Actions ([#955](https://github.com/terraform-google-modules/terraform-example-foundation/issues/955)) ([56450bd](https://github.com/terraform-google-modules/terraform-example-foundation/commit/56450bdd16ca178b4f1191aadc3690b45cbf8f3d))
* add instructions for deployment using GitLab pipelines ([#1047](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1047)) ([0805878](https://github.com/terraform-google-modules/terraform-example-foundation/commit/0805878ff9f5ee5cc2e1fad7a6907a80ba5d28ce))
* add support for fine grained configuration of VPC-flow logs ([#1035](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1035)) ([ee3a1d8](https://github.com/terraform-google-modules/terraform-example-foundation/commit/ee3a1d819b7a81f8fb8195a57f0bbc4ce23c2809))
* Add support for Log Analytics and Remove BigQuery log destination ([#1025](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1025)) ([25c61c4](https://github.com/terraform-google-modules/terraform-example-foundation/commit/25c61c48c94eb530776373bffd668a57b0d79ed8))
* Add support to proxy-only subnetworks and new IP CIDR allocation ([#1040](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1040)) ([79b217e](https://github.com/terraform-google-modules/terraform-example-foundation/commit/79b217ea25ad21a03f07dd4be94dfb736887892e))
* CAI Monitoring Cloud Function ([#1015](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1015)) ([141f067](https://github.com/terraform-google-modules/terraform-example-foundation/commit/141f067430c1a2f17d5698a9e9a88f989c19fbf9))
* change budget alerts to alarm by forecast ([#1037](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1037)) ([8a4c106](https://github.com/terraform-google-modules/terraform-example-foundation/commit/8a4c10627bf4d8ce39ea374ea8a6b1d2d7e314d9))
* Change old firewall to new network-firewall ([#1041](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1041)) ([f2469c1](https://github.com/terraform-google-modules/terraform-example-foundation/commit/f2469c1a966220710968bcc1d2be51eb82b33abb))
* create projects for KMS resources ([#1032](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1032)) ([f16e805](https://github.com/terraform-google-modules/terraform-example-foundation/commit/f16e80570b0eb026887c0c460ef598fadad23644))
* create subfolders for business units in 4-projects step ([#1039](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1039)) ([06084be](https://github.com/terraform-google-modules/terraform-example-foundation/commit/06084befe130c23329b014615a2ccf37145dbcfd))
* **deps:** Expand Terraform Google Provider to v5 (major) ([#1004](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1004)) ([511f5cb](https://github.com/terraform-google-modules/terraform-example-foundation/commit/511f5cb4131e160660fa505c7f70b33a4d6f6aea))
* **deps:** Update Terraform google to v5 ([#1059](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1059)) ([87f3832](https://github.com/terraform-google-modules/terraform-example-foundation/commit/87f3832a5dba424751632c214973e50e75c6af8e))
* Enable CMEK for Terraform state buckets ([#1030](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1030)) ([63906d8](https://github.com/terraform-google-modules/terraform-example-foundation/commit/63906d8186740c634c1ca9b356333a3e85ffd72d))
* Firewall policy rule with resource manager tag ([#1005](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1005)) ([a92e31b](https://github.com/terraform-google-modules/terraform-example-foundation/commit/a92e31b3c6e48ca1c13570e96c88042ec65d868a))
* implementing terraform cloud deploy with agents ([#1034](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1034)) ([2c96a2f](https://github.com/terraform-google-modules/terraform-example-foundation/commit/2c96a2f3f64d608fa6fe4e40fc8807d17305622d))
* make sed and find commands portable between Linux (GNU) and Mac OS (BSD) ([#1043](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1043)) ([62e8c23](https://github.com/terraform-google-modules/terraform-example-foundation/commit/62e8c236e0e00dbdb2451b6d6708679762657d44))
* Network Refactoring ([#991](https://github.com/terraform-google-modules/terraform-example-foundation/issues/991)) ([5f698ed](https://github.com/terraform-google-modules/terraform-example-foundation/commit/5f698ed12e149c722c31c555802471a191ff7865))
* Remove "compute.disableGuestAttributesAccess" org policy ([#1019](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1019)) ([9fac80f](https://github.com/terraform-google-modules/terraform-example-foundation/commit/9fac80ff192025b51d48286f3345b4a18eae93ba))
* update tf-wrapper.sh script to deal with generic folder hierarchy ([#992](https://github.com/terraform-google-modules/terraform-example-foundation/issues/992)) ([4d7e822](https://github.com/terraform-google-modules/terraform-example-foundation/commit/4d7e822b85d6c21c28389e82b3794b9e1554ebc6))


### Bug Fixes

* add cloud build bucket location ([#921](https://github.com/terraform-google-modules/terraform-example-foundation/issues/921)) ([cf3f117](https://github.com/terraform-google-modules/terraform-example-foundation/commit/cf3f1172c0b162acca07c3581dc9c745ca65d417))
* add VPC Flow logs exceptions for REGIONAL_MANAGED_PROXY and INTERNAL_HTTPS_LOAD_BALANCER ([#976](https://github.com/terraform-google-modules/terraform-example-foundation/issues/976)) ([dd4ff91](https://github.com/terraform-google-modules/terraform-example-foundation/commit/dd4ff91b5dfb765160a57cb38d37a466e3c59595))
* alternative deployment methods minor issues fix ([#1065](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1065)) ([e09d174](https://github.com/terraform-google-modules/terraform-example-foundation/commit/e09d1747bc2209b625d765514b4e4d8943c52f13))
* change priority of 'allow-google-apis' firewall rules to prevent collision with the deny all rule ([#972](https://github.com/terraform-google-modules/terraform-example-foundation/issues/972)) ([7205518](https://github.com/terraform-google-modules/terraform-example-foundation/commit/7205518e62b4c296ee6cf51f08cc1f49d69e20ea))
* **CI:** bump request_timeout for 1-org ([#1070](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1070)) ([336487b](https://github.com/terraform-google-modules/terraform-example-foundation/commit/336487bf60b0bc71e21c8ee95fc7cf6a44ae0125))
* correct terraform required_version for optional ([#1003](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1003)) ([5ef089c](https://github.com/terraform-google-modules/terraform-example-foundation/commit/5ef089c56717a98f74100a61d788513fe9c28c55))
* **deps:** update terraform terraform-google-modules/network/google to v7 ([#956](https://github.com/terraform-google-modules/terraform-example-foundation/issues/956)) ([2f54ad6](https://github.com/terraform-google-modules/terraform-example-foundation/commit/2f54ad621404fb2a38df0006f4692fdb0a22ee12))
* Fix missing Terraform module attribution ([#973](https://github.com/terraform-google-modules/terraform-example-foundation/issues/973)) ([d1d2973](https://github.com/terraform-google-modules/terraform-example-foundation/commit/d1d29736987ea31ee74cc20557c46ff3085baf02))
* replace text example of private key with an image in the jenkins readme ([#1027](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1027)) ([325785c](https://github.com/terraform-google-modules/terraform-example-foundation/commit/325785c1b0d811c70a52e81f1c2c2c265e2c763d))
* set the build timeout for the build that creates the Terraform and gcloud image to 20 minutes ([#1071](https://github.com/terraform-google-modules/terraform-example-foundation/issues/1071)) ([7f5ce28](https://github.com/terraform-google-modules/terraform-example-foundation/commit/7f5ce282154e8e112dedf0f847fec0984fb74652))

## [3.0.0](https://github.com/terraform-google-modules/terraform-example-foundation/compare/v2.3.1...v3.0.0) (2022-12-16)


### ⚠ BREAKING CHANGES

* use random_project_id_length ([#891](https://github.com/terraform-google-modules/terraform-example-foundation/issues/891))
* remove unused variables in network-dual-svpc/shared ([#853](https://github.com/terraform-google-modules/terraform-example-foundation/issues/853))
* bump min TF version to 1.3.0 and use optionals ([#831](https://github.com/terraform-google-modules/terraform-example-foundation/issues/831))
* use remote state to read data from previous steps ([#782](https://github.com/terraform-google-modules/terraform-example-foundation/issues/782))
* Configure bring your own service account in bootstrap ([#777](https://github.com/terraform-google-modules/terraform-example-foundation/issues/777))
* add granular service accounts ([#724](https://github.com/terraform-google-modules/terraform-example-foundation/issues/724))
* **deps:** update terraform null to v3 ([#750](https://github.com/terraform-google-modules/terraform-example-foundation/issues/750))
* use branch main for the gcp-policies repository and use controller for Jenkins master ([#738](https://github.com/terraform-google-modules/terraform-example-foundation/issues/738))
* split network step ([#735](https://github.com/terraform-google-modules/terraform-example-foundation/issues/735))

### Features

* add granular service accounts ([#724](https://github.com/terraform-google-modules/terraform-example-foundation/issues/724)) ([4c84d80](https://github.com/terraform-google-modules/terraform-example-foundation/commit/4c84d80a500ccf658f1a8d792d3a78aef8cfaa24))
* add optional groups creation ([#757](https://github.com/terraform-google-modules/terraform-example-foundation/issues/757)) ([5d9f867](https://github.com/terraform-google-modules/terraform-example-foundation/commit/5d9f867ea544738333025a4af21eb18319ff2803))
* Add support for new organization policies ([#863](https://github.com/terraform-google-modules/terraform-example-foundation/issues/863)) ([9c17c13](https://github.com/terraform-google-modules/terraform-example-foundation/commit/9c17c13a5f54953314ebecdf5a963912574e97ea))
* Add support for tags ([#829](https://github.com/terraform-google-modules/terraform-example-foundation/issues/829)) ([a0604b3](https://github.com/terraform-google-modules/terraform-example-foundation/commit/a0604b3aff804e2c33c6d936c72d356c263bfcb1))
* Bring your on Service Account for the App Infra Pipeline ([#824](https://github.com/terraform-google-modules/terraform-example-foundation/issues/824)) ([0d6be42](https://github.com/terraform-google-modules/terraform-example-foundation/commit/0d6be422b8f1f60a8927ae53b3bff698447eb231))
* bump min TF version to 1.3.0 and use optionals ([#831](https://github.com/terraform-google-modules/terraform-example-foundation/issues/831)) ([6207113](https://github.com/terraform-google-modules/terraform-example-foundation/commit/62071133e5e8c98383abbf703d9237938490c581))
* Configure bring your own service account in bootstrap ([#777](https://github.com/terraform-google-modules/terraform-example-foundation/issues/777)) ([015fe3d](https://github.com/terraform-google-modules/terraform-example-foundation/commit/015fe3d5716e9210cc45af9be73ae673e58df5fa))
* Create a workspace for 0-bootstrap ([#866](https://github.com/terraform-google-modules/terraform-example-foundation/issues/866)) ([6e9c575](https://github.com/terraform-google-modules/terraform-example-foundation/commit/6e9c575984066dc97346f9792c7de1eeb3fdcc35))
* Create base environment module for step 4-projects ([#669](https://github.com/terraform-google-modules/terraform-example-foundation/issues/669)) ([7a533bf](https://github.com/terraform-google-modules/terraform-example-foundation/commit/7a533bf0f41bb2e6681c4c58267eb2cce795206c))
* default configuration for VPC-SC should have all supported services ([#864](https://github.com/terraform-google-modules/terraform-example-foundation/issues/864)) ([a496744](https://github.com/terraform-google-modules/terraform-example-foundation/commit/a4967445b4e4c3074d4dcd20dc8297813c3f2ece))
* **deps:** update terraform null to v3 ([#750](https://github.com/terraform-google-modules/terraform-example-foundation/issues/750)) ([b2e8bfc](https://github.com/terraform-google-modules/terraform-example-foundation/commit/b2e8bfc0f1ce846ebf9ae9fcfd9993447f3f9fe0))
* Enable Essential Contacts ([#783](https://github.com/terraform-google-modules/terraform-example-foundation/issues/783)) ([86fcb2a](https://github.com/terraform-google-modules/terraform-example-foundation/commit/86fcb2a4716511d95ded2729f040e56b2d415575))
* Feature/private service connect module ([#722](https://github.com/terraform-google-modules/terraform-example-foundation/issues/722)) ([b3b9145](https://github.com/terraform-google-modules/terraform-example-foundation/commit/b3b9145d1bae356ba01d33d66df55efd9b6e59c0))
* ingress egress support for vpc sc ([#784](https://github.com/terraform-google-modules/terraform-example-foundation/issues/784)) ([c6f12e2](https://github.com/terraform-google-modules/terraform-example-foundation/commit/c6f12e22c735e97ff1644bd8e51cee2eb3941b18))
* Inline App Infra Pipeline `sa_roles` ([#867](https://github.com/terraform-google-modules/terraform-example-foundation/issues/867)) ([33a6619](https://github.com/terraform-google-modules/terraform-example-foundation/commit/33a66192d23da1f02a1849db50315c8c70509a90))
* Modularize logging components ([#781](https://github.com/terraform-google-modules/terraform-example-foundation/issues/781)) ([a1d636e](https://github.com/terraform-google-modules/terraform-example-foundation/commit/a1d636e550d133abffe2240f795d331e9d691c3c))
* new org policies ([#791](https://github.com/terraform-google-modules/terraform-example-foundation/issues/791)) ([878da45](https://github.com/terraform-google-modules/terraform-example-foundation/commit/878da4598d3fa1562e19e1af6a9e5805b13696e4))
* Refactor/centralized network variable ([#665](https://github.com/terraform-google-modules/terraform-example-foundation/issues/665)) ([cdb97bf](https://github.com/terraform-google-modules/terraform-example-foundation/commit/cdb97bf306c316d4dea71d12f41b88bb02a9f92d))
* remove default SA editor role from Seed and CICD projects ([#896](https://github.com/terraform-google-modules/terraform-example-foundation/issues/896)) ([465d3dd](https://github.com/terraform-google-modules/terraform-example-foundation/commit/465d3dd732f105b25da33d454fda3ff2b522d09f))
* Remove redundant optional firewall rules ([#647](https://github.com/terraform-google-modules/terraform-example-foundation/issues/647)) ([6e17729](https://github.com/terraform-google-modules/terraform-example-foundation/commit/6e1772942f08e6cafa9c167f6eff6e9ee8434a25))
* split network step ([#735](https://github.com/terraform-google-modules/terraform-example-foundation/issues/735)) ([512430b](https://github.com/terraform-google-modules/terraform-example-foundation/commit/512430b1982d89834d9c05a8fab1536ead39f3a7))
* update 3-networks to support TPG 4 and other updates ([#733](https://github.com/terraform-google-modules/terraform-example-foundation/issues/733)) ([d940f6e](https://github.com/terraform-google-modules/terraform-example-foundation/commit/d940f6e3401ad3f19987acf56ba70b086bb2a855))
* update document and script to use gcloud beta terraform vet ([#729](https://github.com/terraform-google-modules/terraform-example-foundation/issues/729)) ([d1a56d4](https://github.com/terraform-google-modules/terraform-example-foundation/commit/d1a56d408cdb6ef95da51c685d6beaf5f6a0b07d))
* use branch main for the gcp-policies repository and use controller for Jenkins master ([#738](https://github.com/terraform-google-modules/terraform-example-foundation/issues/738)) ([afc9d71](https://github.com/terraform-google-modules/terraform-example-foundation/commit/afc9d71869674ef85475ec9fefb4961a9d137394))
* Use Cloud build private pools ([#868](https://github.com/terraform-google-modules/terraform-example-foundation/issues/868)) ([ca06365](https://github.com/terraform-google-modules/terraform-example-foundation/commit/ca0636527e2fc79e083c5aa1f62ba77a4daf99bd))
* use random_project_id_length ([dd063aa](https://github.com/terraform-google-modules/terraform-example-foundation/commit/dd063aa144e14d2e2f7f9d65e7503d4dbb55a565))
* use random_project_id_length ([#891](https://github.com/terraform-google-modules/terraform-example-foundation/issues/891)) ([dd063aa](https://github.com/terraform-google-modules/terraform-example-foundation/commit/dd063aa144e14d2e2f7f9d65e7503d4dbb55a565))
* use remote state to read data from previous steps ([#782](https://github.com/terraform-google-modules/terraform-example-foundation/issues/782)) ([a761a99](https://github.com/terraform-google-modules/terraform-example-foundation/commit/a761a99f8f4ad93b7fec37887bc34848015eb091))
* validate requirements script ([#765](https://github.com/terraform-google-modules/terraform-example-foundation/issues/765)) ([84bbd25](https://github.com/terraform-google-modules/terraform-example-foundation/commit/84bbd257095152babdc143a6381a48fd70dbe375))


### Bug Fixes

* add a chmod command for project infra pipeline runners([#657](https://github.com/terraform-google-modules/terraform-example-foundation/issues/657)) ([2730050](https://github.com/terraform-google-modules/terraform-example-foundation/commit/2730050a8ce69e125cc4b2e6d03934d7b34d7a10))
* add note about updating transitivity firewall rules in the Hub and Spoke network mode ([#906](https://github.com/terraform-google-modules/terraform-example-foundation/issues/906)) ([4211162](https://github.com/terraform-google-modules/terraform-example-foundation/commit/4211162958da5f8e9bc98479dbc83be32fa03ec4))
* add onprem_dc variable and add missing routers in hub and spoke base and restricted modules ([#912](https://github.com/terraform-google-modules/terraform-example-foundation/issues/912)) ([83cf36b](https://github.com/terraform-google-modules/terraform-example-foundation/commit/83cf36be878ba4f515bd9a7eafc5a3e878aa2d5a))
* add vpc flow logs configuration for jenkins subnet ([#870](https://github.com/terraform-google-modules/terraform-example-foundation/issues/870)) ([40e391c](https://github.com/terraform-google-modules/terraform-example-foundation/commit/40e391c0edb3650f3a5a940062194e4b12add1b7))
* always grant view permissions at org to CB SA for TFV ([#645](https://github.com/terraform-google-modules/terraform-example-foundation/issues/645)) ([66d4c5b](https://github.com/terraform-google-modules/terraform-example-foundation/commit/66d4c5b3332571f416c06041701a29c5dc82857e))
* backend_bucket &gt; remote_state_bucket ([#848](https://github.com/terraform-google-modules/terraform-example-foundation/issues/848)) ([75c5ab3](https://github.com/terraform-google-modules/terraform-example-foundation/commit/75c5ab31bffaee5f255bd1b48c03bcaac6f738de))
* block project-wide SSH keys ([#897](https://github.com/terraform-google-modules/terraform-example-foundation/issues/897)) ([07e9ab5](https://github.com/terraform-google-modules/terraform-example-foundation/commit/07e9ab52ef39ed6f409caf08d91c92987695f70f))
* bump the version of project factory to 13.0 ([#702](https://github.com/terraform-google-modules/terraform-example-foundation/issues/702)) ([78c7d90](https://github.com/terraform-google-modules/terraform-example-foundation/commit/78c7d906021327f415ed9ca6ed35964a0e28a4cb))
* bump the version of the cloudbuild in the bootstrap step ([#642](https://github.com/terraform-google-modules/terraform-example-foundation/issues/642)) ([3f61dba](https://github.com/terraform-google-modules/terraform-example-foundation/commit/3f61dbaab143d5ca2fdaebb53bb4f858ac4218a8))
* conventional-commit-lint.yaml file must have the default header ([#911](https://github.com/terraform-google-modules/terraform-example-foundation/issues/911)) ([4581750](https://github.com/terraform-google-modules/terraform-example-foundation/commit/4581750627f3cebe56e0c8d089f6834da35b2668))
* create billing dataset in multi-regional by default ([#799](https://github.com/terraform-google-modules/terraform-example-foundation/issues/799)) ([ca0a4b3](https://github.com/terraform-google-modules/terraform-example-foundation/commit/ca0a4b3f85bfeac28206aab9c8d0de158db5752d))
* data_access_logs_enabled now enables read and write audit logs, defaults to false for cost savings ([#630](https://github.com/terraform-google-modules/terraform-example-foundation/issues/630)) ([8391f1b](https://github.com/terraform-google-modules/terraform-example-foundation/commit/8391f1bd4322fec04fda7509b537c5f66cddbbd9))
* enable firewall logging for health check firewall rule ([#892](https://github.com/terraform-google-modules/terraform-example-foundation/issues/892)) ([5fda1f0](https://github.com/terraform-google-modules/terraform-example-foundation/commit/5fda1f099cd2dbe6e03099ebb9c5f2fe9460443c))
* enable missing DNS logging ([#893](https://github.com/terraform-google-modules/terraform-example-foundation/issues/893)) ([9285cd7](https://github.com/terraform-google-modules/terraform-example-foundation/commit/9285cd7e04d88881a3ea036932205dd96fecfb5b))
* exclude version `4.31.0` from the possible versions for infra pipeline module ([#771](https://github.com/terraform-google-modules/terraform-example-foundation/issues/771)) ([37ba8ba](https://github.com/terraform-google-modules/terraform-example-foundation/commit/37ba8ba669475682136d576f5db6c252ab1e193f))
* firewall priorities to use `65530` to align with doc ([#869](https://github.com/terraform-google-modules/terraform-example-foundation/issues/869)) ([1bf4931](https://github.com/terraform-google-modules/terraform-example-foundation/commit/1bf49310e732a448644588a66c75976042461c1e))
* grant permissions required by TFV to CB SA ([#629](https://github.com/terraform-google-modules/terraform-example-foundation/issues/629)) ([ffa6a93](https://github.com/terraform-google-modules/terraform-example-foundation/commit/ffa6a93582bdf242bf273a2ff2e984cf6149bb89))
* Grant role browser to the terraform service account for running gcloud beta terraform vet ([#818](https://github.com/terraform-google-modules/terraform-example-foundation/issues/818)) ([e80a504](https://github.com/terraform-google-modules/terraform-example-foundation/commit/e80a5040cbb9f84a78a6ce56590d7ef187e2d92b))
* hardcode the regions variables in the `3-networks/shared` ([#699](https://github.com/terraform-google-modules/terraform-example-foundation/issues/699)) ([9c320d8](https://github.com/terraform-google-modules/terraform-example-foundation/commit/9c320d8326c9dcd0799093a985fdb0fc2fe7cf04))
* Hub and Spoke build ([#648](https://github.com/terraform-google-modules/terraform-example-foundation/issues/648)) ([98a3441](https://github.com/terraform-google-modules/terraform-example-foundation/commit/98a344146a4852d54aa0ca1302639166a3e2392f))
* Jenkins CI/CD ([#882](https://github.com/terraform-google-modules/terraform-example-foundation/issues/882)) ([26d8fc5](https://github.com/terraform-google-modules/terraform-example-foundation/commit/26d8fc57187368e78c85ad118c4e915743bcc8c5))
* make dedicated interconnect comply with guide ([#913](https://github.com/terraform-google-modules/terraform-example-foundation/issues/913)) ([7d77636](https://github.com/terraform-google-modules/terraform-example-foundation/commit/7d77636479e58091771e1dd232fae88897c55db0))
* make first gcloud builds submit wait for the creation of the default cloud build bucket ([#719](https://github.com/terraform-google-modules/terraform-example-foundation/issues/719)) ([3e2ca41](https://github.com/terraform-google-modules/terraform-example-foundation/commit/3e2ca413d2fd57c309748109f56008be2503ff9a))
* make partner interconnect comply with guide ([#915](https://github.com/terraform-google-modules/terraform-example-foundation/issues/915)) ([4b4f8d8](https://github.com/terraform-google-modules/terraform-example-foundation/commit/4b4f8d8a820781846c471635040a0cd4fcf6f2e1))
* psc endpoints ([#875](https://github.com/terraform-google-modules/terraform-example-foundation/issues/875)) ([730acd6](https://github.com/terraform-google-modules/terraform-example-foundation/commit/730acd663136df3c87c29f656cbd7105b10d9381))
* Remove depends_on in bootstrap ([#850](https://github.com/terraform-google-modules/terraform-example-foundation/issues/850)) ([741648a](https://github.com/terraform-google-modules/terraform-example-foundation/commit/741648a49c1b174a7b0d2206379918dddcb2e87d))
* remove locals related to hub and spoke from dual shared vpc code ([#907](https://github.com/terraform-google-modules/terraform-example-foundation/issues/907)) ([102df23](https://github.com/terraform-google-modules/terraform-example-foundation/commit/102df239f806ce55119c94a014a41a8ba1db6791))
* remove unused variables in network-dual-svpc/shared ([#853](https://github.com/terraform-google-modules/terraform-example-foundation/issues/853)) ([49057b1](https://github.com/terraform-google-modules/terraform-example-foundation/commit/49057b10d1e423cf37cf9313d4a6f0cbbfbe6737))
* Review builds with Jenkins ([#838](https://github.com/terraform-google-modules/terraform-example-foundation/issues/838)) ([82aa221](https://github.com/terraform-google-modules/terraform-example-foundation/commit/82aa221a64c643a03825bed111807da2dfa41b8c))
* sed regex for backend bucket name substitution ([#858](https://github.com/terraform-google-modules/terraform-example-foundation/issues/858)) ([8b5ffc4](https://github.com/terraform-google-modules/terraform-example-foundation/commit/8b5ffc48fbc5daa3b687bf7a92e752ead368d239))
* set random suffix to the same size of other project suffix ([#886](https://github.com/terraform-google-modules/terraform-example-foundation/issues/886)) ([70778eb](https://github.com/terraform-google-modules/terraform-example-foundation/commit/70778eba1d0fc4f8a9a5758697527174c82f787a))
* set the location for cloud build related buckets in step4 based in the default region ([#667](https://github.com/terraform-google-modules/terraform-example-foundation/issues/667)) ([b2b3aca](https://github.com/terraform-google-modules/terraform-example-foundation/commit/b2b3acaaee51942b1f2f90b08c2b79bfc40b4205))
* source repos keys in sa_roles map ([#895](https://github.com/terraform-google-modules/terraform-example-foundation/issues/895)) ([8bd7d14](https://github.com/terraform-google-modules/terraform-example-foundation/commit/8bd7d146528011f19b1f94cbd86f903c24c0cc07))
* tflint fixes ([#909](https://github.com/terraform-google-modules/terraform-example-foundation/issues/909)) ([b437e29](https://github.com/terraform-google-modules/terraform-example-foundation/commit/b437e29544c474d10eb3ba2abc1fd0551a7e2627))
* update bucket naming to comply with guide definition ([#904](https://github.com/terraform-google-modules/terraform-example-foundation/issues/904)) ([49347f5](https://github.com/terraform-google-modules/terraform-example-foundation/commit/49347f57ab50716511c3913f1d3bc2a38df837d1))
* update cloud build private pool peering network CIDR range ([#905](https://github.com/terraform-google-modules/terraform-example-foundation/issues/905)) ([f5615ee](https://github.com/terraform-google-modules/terraform-example-foundation/commit/f5615ee866a34c3984fca0872aa73b43a6db8111))
* update TPG version constraints to allow 4.0 in 5-app-infra ([#721](https://github.com/terraform-google-modules/terraform-example-foundation/issues/721)) ([90f15f2](https://github.com/terraform-google-modules/terraform-example-foundation/commit/90f15f28c03f391dc95aaa843f1a5727772bd8e4))
* updates for on-prem connectivity configuration ([#827](https://github.com/terraform-google-modules/terraform-example-foundation/issues/827)) ([70f9e54](https://github.com/terraform-google-modules/terraform-example-foundation/commit/70f9e5487f52a958ede05e35d5599ed6d4297dad))
* updates for tfv1 compat ([#637](https://github.com/terraform-google-modules/terraform-example-foundation/issues/637)) ([235698b](https://github.com/terraform-google-modules/terraform-example-foundation/commit/235698b4312e1afa1cdf7268c27eba820543b94f))
* VPC Flow Logs constraint issue + Adding gcloud terraform vet usage to test ([#779](https://github.com/terraform-google-modules/terraform-example-foundation/issues/779)) ([0019b00](https://github.com/terraform-google-modules/terraform-example-foundation/commit/0019b006da532b37ec6ed1637ac15a0ccbb9b51b))

### [2.3.1](https://www.github.com/terraform-google-modules/terraform-example-foundation/compare/v2.3.0...v2.3.1) (2021-10-15)


### Bug Fixes

* upgrade cloud router module version ([#559](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/559)) ([b67e62a](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/b67e62adf5e7431209a02dc4b70c3d793db5c6eb))

## [2.3.0](https://www.github.com/terraform-google-modules/terraform-example-foundation/compare/v2.2.0...v2.3.0) (2021-09-02)


### Features

* replace scc gcloud provisioner with native resource ([#514](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/514)) ([d2cdfb6](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/d2cdfb6855b6b26e18358a7456247e93d8861e6d))

## [2.2.0](https://www.github.com/terraform-google-modules/terraform-example-foundation/compare/v2.1.1...v2.2.0) (2021-07-16)


### Features

* Add permissions for SFB recommended groups ([#446](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/446)) ([a18b203](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/a18b2036531d9529778d6a0e6b6c9583a0ec76a2))


### Bug Fixes

* added link to FAQ in 1-org ([#497](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/497)) ([a266e02](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/a266e0275604ea4aff87a64c06ed100f070db520))
* Update project-factory module to 10.1 ([#499](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/499)) ([f46e2e8](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/f46e2e86d18b847bd08497551b58da4794137e4f))

### [2.1.1](https://www.github.com/terraform-google-modules/terraform-example-foundation/compare/v2.1.0...v2.1.1) (2021-06-23)


### Bug Fixes

* add browser role to cloud build sa for provided folders ([#484](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/484)) ([b3996e2](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/b3996e22f3f9f31242a774f99aab360f8467615d))
* upgrade terraform to 0.13.7 ([#490](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/490)) ([a9150a7](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/a9150a7356a94a39be20736513a5e87a0cdfee3b))

## [2.1.0](https://www.github.com/terraform-google-modules/terraform-example-foundation/compare/v2.0.0...v2.1.0) (2021-05-15)


### Features

* add DNS zone for artifact registry ([#480](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/480)) ([7e9f496](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/7e9f496e49d7a725f338b9b514881d47f84a05dd))


### Bug Fixes

* Update bootstrap README.md steps & terraform.example.tfvars ([#470](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/470)) ([86c2547](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/86c254705664f295432915f91b38f9bde9fa2dd0))

## [2.0.0](https://www.github.com/terraform-google-modules/terraform-example-foundation/compare/v1.1.0...v2.0.0) (2021-05-01)


### Features

* 4-projects GCS CMEK example ([#346](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/346)) ([d74ff33](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/d74ff33cb4683372c226a5f203ccf82840980494))
* add FAQ, Glossary & Troubleshooting docs ([#466](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/466)) ([57643a6](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/57643a6b14c0f118b55608eca3ca13aca692ae0f))
* Add GAR in infra pipelines and tests ([#395](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/395)) ([2a2e4fe](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/2a2e4fe6699ab2a4d1172c64532c4199ce5b0c68))
* Add hub and spoke network architecture ([#298](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/298)) ([d9468db](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/d9468db6f8eb24db29e21904ab8b4748d19d5e40))
* add iam.automaticIamGrantsForDefaultServiceAccounts org policy constraint ([#386](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/386)) ([f6b0387](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/f6b0387bc1af908ae13582cb69bf995773cec4bf))
* Add log export GCS bucket object versioning ([#317](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/317)) ([cb0e622](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/cb0e622becb7af6ddf7ef4d40adfe48397246d45))
* add Shielded VMs & OS Login org policies ([#283](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/283)) ([07a201e](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/07a201e46f65c3a2587273f19ce438aab8907d12))
* Add step 5-app-infra ([#382](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/382)) ([fd5329c](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/fd5329ca1394c6fc1ec6edf33ade44ea83303cd1))
* add support for hierarchical firewall policies ([#343](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/343)) ([e7bb1bc](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/e7bb1bc6a565acb02626002712186887e715b0fa))
* Add terraform validator and add policy-library ([#263](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/263)) ([f220588](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/f220588412c433ffb150f534ff956913feddfaff))
* Adds prefix to projects and folder name ([#289](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/289)) ([66dacf2](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/66dacf23f22e8812211c3c895b31429af7cf74e8))
* App Infra pipelines ([#337](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/337)) ([c3b19e8](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/c3b19e81ffbc1533f6ba91b17889abaea2eea89d))
* enable hub & spoke transitivity via gateway VMs ([#322](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/322)) ([f6cd9ad](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/f6cd9ad4b63e71ab93a46e10f1584dc4a1c65a93))
* example-foundations test modes ([#309](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/309)) ([34a6d75](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/34a6d75546b94cb672003cda4173718e041f720b))
* implement support for Partner Interconnect ([#345](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/345)) ([70501ec](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/70501ec7a2f84ebf41b11d8b9fefe5d9d7398698))
* Make BigQuery log destinations partitioned ([#277](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/277)) ([f40c5fe](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/f40c5fe40fa39df5d115475df6b89bd71c0042f9))
* Move Cloud Source Repo definition to variable. ([#302](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/302)) ([48037c9](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/48037c9ac8d76c62bc35e5e4ba7c20e769746091))
* Replace container registry with artifact registry in CloudBuild ([#367](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/367)) ([6b6469b](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/6b6469b8dc21b846a08f51ed2bec54150b5e104c))
* Update terraform-validator version, instructions and CMEK bucket ([#397](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/397)) ([8f7c58e](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/8f7c58ef5b3175fb9000fbe227b73f4ffb213c13))
* updates to support TF 0.13 ([#268](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/268)) ([c5c6c6c](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/c5c6c6c3e3a66ae1000ec49e2f7e78ed2cd08e3d))


### Bug Fixes

* 1-org README.md add setting up Security Command Center to Prerequisites ([#467](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/467)) ([ee04cb5](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/ee04cb5c2f4fc3b96ab7881251cf5c0e565a3a3b))
* add bucket prefix for bootstrap ([#407](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/407)) ([03bd05a](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/03bd05a64ed691c035fa99ac28382b251fd997e4))
* add cloudbuild api to seed proj ([#358](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/358)) ([1fda12b](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/1fda12bc78902343532fa476ef7755cba7a49010))
* add CMEK project name prefix and root readme project names ([#414](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/414)) ([141c059](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/141c059c4ca184a7b23c7c7f69dc22a3e7f8a339))
* add impersonate to gcloud builds submit command in infra-pipeline module ([#458](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/458)) ([1d3fbf8](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/1d3fbf82ee7acfa016be31662d79e46e65e45fa1))
* add infra pipeline CB SA role test ([#450](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/450)) ([e30fe8c](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/e30fe8cbd267b9f2e5dad9bc8fdb4360880b1cd4))
* add missing google apis to policy constraint ([#370](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/370)) ([2ac0466](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/2ac046691abcb3a717122063bbc95b31547c9437))
* Add missing symlink in shared network env ([#328](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/328)) ([48c2318](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/48c2318ea64fc8533a45eafddea1196e9975f089))
* add network fixture prepare to lint test ([#323](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/323)) ([c120d55](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/c120d555b45ff32fe10b9e5d18aa4f2c6b915885))
* add standalone repo for terraform-validator policies ([#403](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/403)) ([b170478](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/b1704781ba4a004de5ba8917feded5361259ce12))
* Adding KMS API in bootstrap project ([#385](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/385)) ([39b8da3](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/39b8da37b342a51a2b88f9910b95f11b85512e8f))
* Bugfix/fix 4-projects issues ([#374](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/374)) ([f5f5224](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/f5f5224e3d56732e114179429b14dd66837a3a75))
* clone policies repo once per build ([#329](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/329)) ([3e95111](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/3e95111e9338bd98cb71c0bc34a263d560b58fb5))
* default sa deprivilege ([ea5fcc2](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/ea5fcc2f9d5444e2e53332c77fc01fb48996fe2c))
* Documentation fixes ([#327](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/327)) ([ce610d0](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/ce610d0c8a71316c5c9f83136e9738e7eb3df933))
* Documentation language inconsistencies, typos and tests ([#419](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/419)) ([71b633f](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/71b633fa0f6d09677fbbc7d740ebdc20a3aba126))
* Fixes for build stability issues ([#406](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/406)) ([c2b8200](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/c2b8200e49a718febc071d17c40ea6dfe1e49578))
* pin versions of terraform in the code to version 0.13.6 ([#398](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/398)) ([b86457c](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/b86457cb6bec978bed6997c73d982204468131b9))
* remove shielded VM org policy ([#286](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/286)) ([c1a2852](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/c1a28526c22a05d7d0ef0ca56d3811b45226e760))
* rename access_context.tfvars to access_context.auto.tfvars in 4-projects ([#396](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/396)) ([91ce3f8](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/91ce3f8c598138bef7901d70cde645fe11685c36))
* set 3-networks service account token lifetime to 1200s ([#432](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/432)) ([76efbe8](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/76efbe85d8eddb801cde91da7eef8028f4900e45))
* specify ports for ssh & rdp for IAP TCP forwarding rule ([#390](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/390)) ([3eed2bc](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/3eed2bc96728c4c9239634bfb2294aee8805639a))
* support for hub and spoke transitivity ([#427](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/427)) ([a6b43da](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/a6b43da4bb06981fafc38264c840e124ca473fbf))
* update 4-projects infra pipeline project name ([#404](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/404)) ([7beb5a0](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/7beb5a0a8e83ba95b39438189819ccdbcc1ab1d3))
* update documentation ([#301](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/301)) ([54aa58a](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/54aa58a1eb686f9c52d874b285ba44ab87fb7391))
* Update google cloud sdk min version to 319.0.0 and use GA version of gcloud scc notifications ([#463](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/463)) ([ebbb4d7](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/ebbb4d7c41cfc97240e83dc58a3c5299b9c0f2b6))
* update google-beta provider source info ([#368](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/368)) ([9924760](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/9924760367c13af6672261eacaaffefa98ec40d2))
* Update readme files ([#399](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/399)) ([d1f29c3](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/d1f29c36dd5aced7c80fb5a99c1ea54527d608ab))
* upgrade version for dependant CFT modules ([#339](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/339)) ([02a4ac5](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/02a4ac54de04d1fa999a1e2a5b5d8e84e8c8533d))
* use f1-micro as the machine type for the deploy in 5-app-infra step ([#416](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/416)) ([1fad10b](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/1fad10b2af93069a7369cd100a3fcf2cddaa6f74))
* version of network_peering in step 4-projects ([#384](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/384)) ([16a99bb](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/16a99bb4a00f5ed669ac5f70c5d0972002b51c95))

## [1.1.0](https://www.github.com/terraform-google-modules/terraform-example-foundation/compare/v1.0.0...v1.1.0) (2021-03-10)


### Features

* add integration tests for 4-projects ([#232](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/232)) ([0521aeb](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/0521aebc268f47fca732458a55e899ab3c9c27c1))
* Add Provider cache ([#250](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/250)) ([5c5b8b3](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/5c5b8b377494751cae70314976420ab04ddc5e55))
* add terraform show command to wrapper script ([#267](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/267)) ([2a8e9f2](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/2a8e9f215072f65cb28f919e5e2cdb6d8a4475bc))
* adds jenkins agent vpn automation in terraform ([#234](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/234)) ([68208ad](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/68208adee1e15d0bc8dd2aca5bfc260a90a76e8d))
* adds kitchen testes for step 3-networks ([#231](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/231)) ([50bab16](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/50bab16be43dbf8066dc711e1e3af2192a788f0a))
* Adds org policy admin role for admin group ([#262](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/262)) ([12f02ec](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/12f02ecf91d55ba5b8fe0044a3512ecc13f37031))
* Adds peering project examples ([#243](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/243)) ([dc6dd95](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/dc6dd9583ab6822a06fa7448b5434b524b18f0b0))
* adds support for bucket retention policy for logs ([#266](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/266)) ([cc4ddbc](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/cc4ddbccdd6a5f1208528c656445adcc0a77f3a7))


### Bug Fixes

* 3-networks inconsistencies and typos ([#304](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/304)) ([f87ed16](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/f87ed1661bec7c2d2c75ea091d1cf5db6ac6943a))
* adjust log filters for SHA/CIS compliance ([#261](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/261)) ([cd42805](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/cd428055b326d77ff7770460b36bfcc8e656b8d8))
* deprecated bucket-policy-only parameter and bq table deletion ([#264](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/264)) ([3dfda65](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/3dfda65cdac22f3d24f5aaa16e46b52408936690))
* egress deny fw rule for all protocols ([#260](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/260)) ([402c785](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/402c7851e33ea29b56e74e8a316b8f2fbe1a4d2e))
* enable data access logs collection ([#249](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/249)) ([6e887e0](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/6e887e028195eabf7e630b86d529196bd33db1a4))
* explicitly add project to scc pub/sub topic creation ([#233](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/233)) ([ca7d926](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/ca7d926869477f33a82bf0a5157ff0b32c6575c2))
* Pin network module for terraform 0.12 ([#333](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/333)) ([f0218a5](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/f0218a5a30d230ed2083bc4c465fe799dd417034))
* set default_service_account value correctly to 'deprivilege' ([#282](https://www.github.com/terraform-google-modules/terraform-example-foundation/issues/282)) ([6f8a4c0](https://www.github.com/terraform-google-modules/terraform-example-foundation/commit/6f8a4c0a21aaad66e293e64306414baa924b04d3))
