# Code Engine job module

You can use this submodule to provision IBM [Code Engine Job](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started).


### Usage
```hcl
provider "ibm" {
  ibmcloud_api_key = "XXXXXXXXXX" # pragma: allowlist secret
  region           = "us-south"
}

module "job" {
  source        = "terraform-ibm-modules/code-engine/ibm//modules/job"
  version       = "latest" # Replace "latest" with a release version to lock into a specific release
  project_id    = "project_id"
  name          = "job_name"
  image_reference = "icr.io/codeengine/helloworld"
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
| <a name="requirement_terraform"></a> [terraform](#requirement\_terraform) | >= 1.9.0 |
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.74.0, <2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_code_engine_job.ce_job](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_job) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_image_reference"></a> [image\_reference](#input\_image\_reference) | The name of the image that is used for this job. | `string` | n/a | yes |
| <a name="input_image_secret"></a> [image\_secret](#input\_image\_secret) | The name of the image registry access secret. | `string` | `null` | no |
| <a name="input_name"></a> [name](#input\_name) | The name of the job. | `string` | n/a | yes |
| <a name="input_project_id"></a> [project\_id](#input\_project\_id) | The ID of the project where job will be created. | `string` | n/a | yes |
| <a name="input_run_arguments"></a> [run\_arguments](#input\_run\_arguments) | Arguments for the app that are passed to start the container. | `list(string)` | `[]` | no |
| <a name="input_run_as_user"></a> [run\_as\_user](#input\_run\_as\_user) | The user ID (UID) to run the app. | `number` | `null` | no |
| <a name="input_run_commands"></a> [run\_commands](#input\_run\_commands) | Commands for the app that are passed to start the container. | `list(string)` | `[]` | no |
| <a name="input_run_env_variables"></a> [run\_env\_variables](#input\_run\_env\_variables) | References to config maps, secrets or a literal values that are exposed as environment variables within the running application. | <pre>list(object({<br/>    type      = optional(string)<br/>    name      = optional(string)<br/>    value     = optional(string)<br/>    prefix    = optional(string)<br/>    key       = optional(string)<br/>    reference = optional(string)<br/>  }))</pre> | `[]` | no |
| <a name="input_run_mode"></a> [run\_mode](#input\_run\_mode) | Commands for the app that are passed to start the container. | `string` | `"task"` | no |
| <a name="input_run_service_account"></a> [run\_service\_account](#input\_run\_service\_account) | The name of the service account. | `string` | `"default"` | no |
| <a name="input_run_volume_mounts"></a> [run\_volume\_mounts](#input\_run\_volume\_mounts) | Optional mounts of config maps or a secrets. | <pre>list(object({<br/>    mount_path = string<br/>    reference  = string<br/>    name       = optional(string)<br/>    type       = string<br/>  }))</pre> | `[]` | no |
| <a name="input_scale_array_spec"></a> [scale\_array\_spec](#input\_scale\_array\_spec) | Define a custom set of array indices as comma-separated list containing single values and hyphen-separated ranges like 5,12-14,23,27. | `string` | `null` | no |
| <a name="input_scale_cpu_limit"></a> [scale\_cpu\_limit](#input\_scale\_cpu\_limit) | The number of CPU set for the instance of the app. | `string` | `"1"` | no |
| <a name="input_scale_ephemeral_storage_limit"></a> [scale\_ephemeral\_storage\_limit](#input\_scale\_ephemeral\_storage\_limit) | The amount of ephemeral storage to set for the instance of the app. | `string` | `"400M"` | no |
| <a name="input_scale_max_execution_time"></a> [scale\_max\_execution\_time](#input\_scale\_max\_execution\_time) | The maximum execution time in seconds for runs of the job. | `number` | `7200` | no |
| <a name="input_scale_memory_limit"></a> [scale\_memory\_limit](#input\_scale\_memory\_limit) | The amount of memory set for the instance of the app. | `string` | `"4G"` | no |
| <a name="input_scale_retry_limit"></a> [scale\_retry\_limit](#input\_scale\_retry\_limit) | The number of times to rerun an instance of the job before the job is marked as failed. | `number` | `3` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_id"></a> [id](#output\_id) | The unique identifier of the created code engine job. |
| <a name="output_job_id"></a> [job\_id](#output\_job\_id) | The ID of the created code engine job. |
| <a name="output_name"></a> [name](#output\_name) | The name of the created code engine job. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->
