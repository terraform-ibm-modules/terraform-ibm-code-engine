# Code Engine domain mapping module

You can use this submodule to provision IBM [Code Engine Domain Mapping](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started).


### Usage
```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX" # pragma: allowlist secret
  region           = "us-south"
}

module "domain_mapping" {
  source        = "terraform-ibm-modules/code-engine/ibm//modules/domain_mapping"
  version       = "latest" # Replace "latest" with a release version to lock into a specific release
  project_id    = "project_id"
  name          = "domain_mapping_name"
  tls_secret    = "my_tls_secret" # pragma: allowlist secret
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.3.0, <1.7.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.63.0, <2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_code_engine_domain_mapping.ce_domain_mapping](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_domain_mapping) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_components"></a> [components](#input\_components) | A reference to another component. | <pre>list(object({<br>    name          = string<br>    resource_type = string<br>  }))</pre> | n/a | yes |
| <a name="input_name"></a> [name](#input\_name) | The name of the domain mapping. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project where domain mapping will be created. | `string` | n/a | yes |
| <a name="input_tls_secret"></a> [tls\_secret](#input\_tls\_secret) | The name of the TLS secret that holds the certificate and private key of this domain mapping. | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_domain_mapping_id"></a> [domain\_mapping\_id](#output\_domain\_mapping\_id) | The ID of the created code engine domain mapping. |
| <a name="output_id"></a> [id](#output\_id) | The unique identifier of the created code engine domain mapping. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
