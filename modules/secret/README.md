# Code Engine secret module

You can use this submodule to provision IBM [Code Engine Secret](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started).


### Usage
```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX" # pragma: allowlist secret
  region           = "us-south"
}

module "secret" {
  source     = "terraform-ibm-modules/code-engine/ibm//modules/secret"
  version    = "latest" # Replace "latest" with a release version to lock into a specific release
  project_id = "project_id"
  name       = "secret_name"
  format     = "generic"
  data       = { "secret_key_1" : "secret_value_1", "secret_key_2" : "secret_value_2" }
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
| [ibm_code_engine_secret.ce_secret](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_secret) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_data"></a> [data](#input\_data) | Data container that allows to specify config parameters and their values as a key-value map. | `map(string)` | `{}` | no |
| <a name="input_format"></a> [format](#input\_format) | Specify the format of the secret. | `string` | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the secret. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project where secret will be created. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The unique identifier of the created code engine secret. |
| <a name="output_secret_id"></a> [secret\_id](#output\_secret\_id) | The ID of the created code engine secret. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
