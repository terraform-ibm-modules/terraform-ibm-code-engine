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
| [ibm_code_engine_app.ce_app](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_app) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_image_port"></a> [image\_port](#input\_image\_port) | The port which is used to connect to the port that is exposed by the container image. | `number` | `8080` | no |
| <a name="input_image_reference"></a> [image\_reference](#input\_image\_reference) | The name of the image that is used for the app. | `string` | n/a | yes |
| <a name="input_image_secret"></a> [image\_secret](#input\_image\_secret) | The name of the image registry access secret. | `string` | `null` | no |
| <a name="input_managed_domain_mappings"></a> [managed\_domain\_mappings](#input\_managed\_domain\_mappings) | Specify which of the following values for the system-managed domain mappings to set up for the application: `local_public`, `local_private`, and `local`. See https://cloud.ibm.com/docs/codeengine?topic=codeengine-application-workloads#optionsvisibility | `string` | `"local_public"` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the app. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project where app will be created. | `string` | n/a | yes |
| <a name="input_run_arguments"></a> [run\_arguments](#input\_run\_arguments) | Arguments for the app that are passed to start the container. | `list(string)` | `[]` | no |
| <a name="input_run_as_user"></a> [run\_as\_user](#input\_run\_as\_user) | The user ID (UID) to run the app. | `number` | `null` | no |
| <a name="input_run_commands"></a> [run\_commands](#input\_run\_commands) | Commands for the app that are passed to start the container. | `list(string)` | `[]` | no |
| <a name="input_run_env_variables"></a> [run\_env\_variables](#input\_run\_env\_variables) | References to config maps, secrets or a literal values that are exposed as environment variables within the running application. | <pre>list(object({<br/>    type      = optional(string)<br/>    name      = optional(string)<br/>    value     = optional(string)<br/>    prefix    = optional(string)<br/>    key       = optional(string)<br/>    reference = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_run_service_account"></a> [run\_service\_account](#input\_run\_service\_account) | The name of the service account. | `string` | `"default"` | no |
| <a name="input_run_volume_mounts"></a> [run\_volume\_mounts](#input\_run\_volume\_mounts) | Optional mounts of config maps or a secrets. | <pre>list(object({<br/>    mount_path = string<br/>    reference  = string<br/>    name       = optional(string)<br/>    type       = string<br/>  }))</pre> | `[]` | no |
| <a name="input_scale_concurrency"></a> [scale\_concurrency](#input\_scale\_concurrency) | The maximum number of requests that can be processed concurrently per instance. | `number` | `100` | no |
| <a name="input_scale_concurrency_target"></a> [scale\_concurrency\_target](#input\_scale\_concurrency\_target) | The threshold of concurrent requests per instance at which one or more additional instances are created. | `number` | `null` | no |
| <a name="input_scale_cpu_limit"></a> [scale\_cpu\_limit](#input\_scale\_cpu\_limit) | The number of CPU set for the instance of the app. | `string` | `"1"` | no |
| <a name="input_scale_ephemeral_storage_limit"></a> [scale\_ephemeral\_storage\_limit](#input\_scale\_ephemeral\_storage\_limit) | The amount of ephemeral storage to set for the instance of the app. | `string` | `"400M"` | no |
| <a name="input_scale_initial_instances"></a> [scale\_initial\_instances](#input\_scale\_initial\_instances) | The initial number of instances that are created upon app creation or app update. | `number` | `1` | no |
| <a name="input_scale_max_instances"></a> [scale\_max\_instances](#input\_scale\_max\_instances) | The maximum number of instances for this app. | `number` | `10` | no |
| <a name="input_scale_memory_limit"></a> [scale\_memory\_limit](#input\_scale\_memory\_limit) | The amount of memory set for the instance of the app. | `string` | `"4G"` | no |
| <a name="input_scale_min_instances"></a> [scale\_min\_instances](#input\_scale\_min\_instances) | The minimum number of instances for this app.  If you set this value to 0, the app will scale down to zero, if not hit by any request for some time. | `number` | `0` | no |
| <a name="input_scale_request_timeout"></a> [scale\_request\_timeout](#input\_scale\_request\_timeout) | The amount of time in seconds that is allowed for a running app to respond to a request. | `number` | `300` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_app_id"></a> [app\_id](#output\_app\_id) | The ID of the created code engine app. |
| <a name="output_endpoint"></a> [endpoint](#output\_endpoint) | URL to application. Depending on visibility this is accessible publicly or in the private network only. |
| <a name="output_endpoint_internal"></a> [endpoint\_internal](#output\_endpoint\_internal) | URL to application that is only visible within the project. |
| <a name="output_id"></a> [id](#output\_id) | The unique identifier of the created code engine app. |
| <a name="output_name"></a> [name](#output\_name) | The name of the created code engine app. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
