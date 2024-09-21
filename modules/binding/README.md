# Code Engine binding module

You can use this submodule to provision IBM [Code Engine Binding](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started).


### Usage
```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX" # pragma: allowlist secret
  region           = "us-south"
}

module "binding" {
  source      = "terraform-ibm-modules/code-engine/ibm//modules/binding"
  version     = "latest" # Replace "latest" with a release version to lock into a specific release
  project_id  = "project_id"
  prefix      = "prefix"
  secret_name = "my-secret"
  components  = [{
                  name          = "app_name"
                  resource_type = "app_v2"
                }]
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.63.0, <2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_code_engine_binding.ce_binding](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_binding) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_components"></a> [components](#input\_components) | A reference to another component. | <pre>list(object({<br/>    name          = string<br/>    resource_type = string<br/>  }))</pre> | n/a | yes |
| <a name="input_prefix"></a> [prefix](#input\_prefix) | Value that is set as prefix in the component that is bound. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project where binding will be created. | `string` | n/a | yes |
| <a name="input_secret_name"></a> [secret\_name](#input\_secret\_name) | The service access secret that is binding to a component. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_binding_id"></a> [binding\_id](#output\_binding\_id) | The ID of the created code engine binding. |
| <a name="output_id"></a> [id](#output\_id) | The unique identifier of the created code engine binding. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
