# Code Engine project module

You can use this submodule to provision IBM [Code Engine Project](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started).


### Usage
```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX" # pragma: allowlist secret
  region           = "us-south"
}

module "secret" {
  source             = "terraform-ibm-modules/code-engine/ibm//modules/project"
  version            = "latest" # Replace "latest" with a release version to lock into a specific release
  name               = "project_name"
  resource_group_id  = "XxxXXxxX-XxxX-XxxX-XxxX-XxxXXxxXXxxX"
  data               = { "secret_key_1" : "secret_value_1", "secret_key_2" : "secret_value_2" }
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
| [ibm_code_engine_project.ce_project](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_project) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_name"></a> [name](#input\_name) | The name of the project. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | ID of resource group to use when creating resources | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The unique identifier of the created code engine project. |
| <a name="output_name"></a> [name](#output\_name) | The name of the created code engine project. |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | The ID of the created code engine project. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
