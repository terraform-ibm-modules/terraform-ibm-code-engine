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

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_code_engine_build.ce_build](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_build) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the build. | `string` | n/a | yes |
| <a name="input_output_image"></a> [output\_image](#input\_output\_image) | The name of the image. | `string` | n/a | yes |
| <a name="input_output_secret"></a> [output\_secret](#input\_output\_secret) | The secret that is required to access the image registry. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project where build will be created. | `string` | n/a | yes |
| <a name="input_source_context_dir"></a> [source\_context\_dir](#input\_source\_context\_dir) | The directory in the repository that contains the buildpacks file or the Dockerfile. | `string` | `null` | no |
| <a name="input_source_revision"></a> [source\_revision](#input\_source\_revision) | Commit, tag, or branch in the source repository to pull. | `string` | `null` | no |
| <a name="input_source_secret"></a> [source\_secret](#input\_source\_secret) | The name of the secret that is used access the repository source. If the var.source\_type value is `local`, this field must be omitted. | `string` | `null` | no |
| <a name="input_source_type"></a> [source\_type](#input\_source\_type) | Specifies the type of source to determine if your build source is in a repository or based on local source code. | `string` | `null` | no |
| <a name="input_source_url"></a> [source\_url](#input\_source\_url) | The URL of the code repository. | `string` | n/a | yes |
| <a name="input_strategy_size"></a> [strategy\_size](#input\_strategy\_size) | The size for the build, which determines the amount of resources used. | `string` | `null` | no |
| <a name="input_strategy_spec_file"></a> [strategy\_spec\_file](#input\_strategy\_spec\_file) | The path to the specification file that is used for build strategies for building an image. | `string` | `null` | no |
| <a name="input_strategy_type"></a> [strategy\_type](#input\_strategy\_type) | The strategy to use for building the image. | `string` | n/a | yes |
| <a name="input_timeout"></a> [timeout](#input\_timeout) | The maximum amount of time, in seconds, that can pass before the build must succeed or fail. | `number` | `600` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_build_id"></a> [build\_id](#output\_build\_id) | The ID of the created code engine build. |
| <a name="output_id"></a> [id](#output\_id) | The unique identifier of the created code engine build. |
| <a name="output_name"></a> [name](#output\_name) | The name of the created code engine build. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
