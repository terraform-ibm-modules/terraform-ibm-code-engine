# Code Engine config map module

You can use this submodule to provision IBM [Code Engine Config Map](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started).


### Usage
```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX" # pragma: allowlist secret
  region           = "us-south"
}

module "config_map" {
  source        = "terraform-ibm-modules/code-engine/ibm//modules/config_map"
  version       = "latest" # Replace "latest" with a release version to lock into a specific release
  project_id    = "project_id"
  name          = "config_map_name"
  data = { "config_map_key_1" : "config_map_value_1", "config_map_key_2" : "config_map_value_2" }
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
| [ibm_code_engine_config_map.ce_config_map](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_config_map) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data"></a> [data](#input\_data) | The key-value pair for the config map. | `map(string)` | `{}` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the config map. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project where config map will be created. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_config_map_id"></a> [config\_map\_id](#output\_config\_map\_id) | The ID of the created code engine config map. |
| <a name="output_data"></a> [data](#output\_data) | The code engine config map's data. |
| <a name="output_id"></a> [id](#output\_id) | The unique identifier of the created code engine config map. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
