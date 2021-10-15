# Changelog

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
