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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, <1.7.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.63.0, <2.0.0 |

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
| <a name="input_source_url"></a> [source\_url](#input\_source\_url) | The URL of the code repository. | `string` | n/a | yes |
| <a name="input_strategy_type"></a> [strategy\_type](#input\_strategy\_type) | Specifies the type of source to determine if your build source is in a repository or based on local source code. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_build_id"></a> [build\_id](#output\_build\_id) | The ID of the created code engine build. |
| <a name="output_id"></a> [id](#output\_id) | The unique identifier of the created code engine build. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
