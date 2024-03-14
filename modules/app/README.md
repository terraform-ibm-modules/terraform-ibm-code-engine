# Code Engine app module

You can use this submodule to provision IBM [Code Engine App](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started).


### Usage
```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX" # pragma: allowlist secret
  region           = "us-south"
}

module "app" {
  source  = "terraform-ibm-modules/code-engine/ibm//modules/app"
  version = "latest" # Replace "latest" with a release version to lock into a specific release
  project_id        = "project_id"
  name              = "app_name"
  image_reference   = "icr.io/codeengine/helloworld"
  run_env_variables = [{
        type  = "literal"
        name  = "env_name"
        value = "env_value"
    }]
}
```

### Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
- IAM Services
    - **IBM Cloud Object Storage** service
        - `Editor` platform access
        - `Manager` service access

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
| [ibm_code_engine_app.ce_app](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_app) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_image_reference"></a> [image\_reference](#input\_image\_reference) | The name of the image that is used for the app. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the app. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project where app will be created. | `string` | n/a | yes |
| <a name="input_run_env_variables"></a> [run\_env\_variables](#input\_run\_env\_variables) | Optional references to config maps, secrets or a literal values that are exposed as environment variables within the running application. | <pre>list(object({<br>    type = string<br>    name = string<br>  value = string }))</pre> | `[]` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_id"></a> [app\_id](#output\_app\_id) | The ID of the created code engine app. |
| <a name="output_id"></a> [id](#output\_id) | The unique identifier of the created code engine app. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
