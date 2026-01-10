# Code Engine binding module

You can use this submodule to provision IBM [Code Engine Build](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started).


### Usage
```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX" # pragma: allowlist secret
  region           = "us-south"
}

module "build" {
  source        = "terraform-ibm-modules/code-engine/ibm//modules/build"
  version       = "latest" # Replace "latest" with a release version to lock into a specific release
  project_id    = "project_id"
  name          = "BUILD_NAME"
  output_secret = "my-secret" # pragma: allowlist secret
  source_url    = "https://github.com/IBM/project"
  strategy_type = "dockerfile"
}
```

### Required IAM access policies

You need the following permissions to run this module.

- IAM Services
    - **Code Engine** service
        - `Editor` platform access
        - `Writer` service access

<!-- BEGINNING OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
### Requirements

| Name | Version |
|------|---------|
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.79.0, <2.0.0 |

### Modules

| Name | Source | Version |
|------|--------|---------|
| <a name="module_cr_endpoint"></a> [cr\_endpoint](#module\_cr\_endpoint) | terraform-ibm-modules/container-registry/ibm//modules/endpoint | 2.6.2 |
| <a name="module_cr_namespace"></a> [cr\_namespace](#module\_cr\_namespace) | terraform-ibm-modules/container-registry/ibm | 2.6.2 |
| <a name="module_secret"></a> [secret](#module\_secret) | ../../modules/secret | n/a |

### Resources

| Name | Type |
|------|------|
| [ibm_code_engine_build.ce_build](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_build) | resource |
| [terraform_data.run_build](https://registry.terraform.io/providers/hashicorp/terraform/latest/docs/resources/data) | resource |
| [ibm_code_engine_project.code_engine_project](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/data-sources/code_engine_project) | data source |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_container_registry_api_key"></a> [container\_registry\_api\_key](#input\_container\_registry\_api\_key) | The API key for the container registry in the target account. This is only used if 'output\_secret' is not set and a new registry secret needs to be created. If not provided, the IBM Cloud API key (ibmcloud\_api\_key) will be used instead. | `string` | `null` | no |
| <a name="input_container_registry_namespace"></a> [container\_registry\_namespace](#input\_container\_registry\_namespace) | The name of the namespace to create in IBM Cloud Container Registry for organizing container images. Must be set if 'output\_image' is not set. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<container_registry_namespace>` format. | `string` | `null` | no |
| <a name="input_existing_resource_group_id"></a> [existing\_resource\_group\_id](#input\_existing\_resource\_group\_id) | The ID of an existing resource group where build will be provisioned. This must be the same resource group in which the code engine project was created. | `string` | n/a | yes |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the build. | `string` | n/a | yes |
| <a name="input_output_image"></a> [output\_image](#input\_output\_image) | A container image can be identified by a container image reference with the following structure: registry / namespace / repository:tag. [Learn more](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started).<br/><br/>If not provided, the value will be derived from the 'container\_registry\_namespace' input variable, which must not be null in that case. | `string` | `null` | no |
| <a name="input_output_secret"></a> [output\_secret](#input\_output\_secret) | The name of the Code Engine secret that contains an API key to access the IBM Cloud Container Registry.<br/>The API key stored in this secret must have push permissions for the specified container registry namespace.<br/>If this secret is not provided, a Code Engine secret named `<prefix>-<registry-access-secret>` will be created automatically. Its value will be taken from 'container\_registry\_api\_key' if set, otherwise from 'ibmcloud\_api\_key'. | `string` | `null` | no |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Prefix appended to the container registry namespace and registry secret if created. | `string` | `null` | no |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project where build will be created. | `string` | n/a | yes |
| <a name="input_region"></a> [region](#input\_region) | The region in which to provision the build. This must be the same region in which the code engine project was created. | `string` | `"us-south"` | no |
| <a name="input_source_context_dir"></a> [source\_context\_dir](#input\_source\_context\_dir) | The directory in the repository that contains the buildpacks file or the Dockerfile. | `string` | `null` | no |
| <a name="input_source_revision"></a> [source\_revision](#input\_source\_revision) | Commit, tag, or branch in the source repository to pull. | `string` | `null` | no |
| <a name="input_source_secret"></a> [source\_secret](#input\_source\_secret) | The name of the secret that is used access the repository source. If the var.source\_type value is `local`, this input must be omitted. | `string` | `null` | no |
| <a name="input_source_type"></a> [source\_type](#input\_source\_type) | Specifies the type of source to determine if your build source is in a repository or based on local source code. If the value is `local`, then 'source\_secret' input must be omitted. | `string` | `null` | no |
| <a name="input_source_url"></a> [source\_url](#input\_source\_url) | The URL of the code repository. | `string` | n/a | yes |
| <a name="input_strategy_size"></a> [strategy\_size](#input\_strategy\_size) | The size for the build, which determines the amount of resources used. | `string` | `null` | no |
| <a name="input_strategy_spec_file"></a> [strategy\_spec\_file](#input\_strategy\_spec\_file) | The path to the specification file that is used for build strategies for building an image. | `string` | `null` | no |
| <a name="input_strategy_type"></a> [strategy\_type](#input\_strategy\_type) | The strategy to use for building the image. | `string` | `"dockerfile"` | no |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | The maximum amount of time, in seconds, that can pass before the build must succeed or fail. | `number` | `600` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_build_id"></a> [build\_id](#output\_build\_id) | The ID of the created code engine build. |
| <a name="output_id"></a> [id](#output\_id) | The unique identifier of the created code engine build. |
| <a name="output_name"></a> [name](#output\_name) | The name of the created code engine build. |
| <a name="output_output_image"></a> [output\_image](#output\_output\_image) | The container image reference of the created code engine build. |
| <a name="output_output_secret"></a> [output\_secret](#output\_output\_secret) | The registry secret of the created code engine build. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
