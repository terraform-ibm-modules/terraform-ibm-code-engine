<!-- Update the title -->
# Terraform Code Engine Module

[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-code-engine?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-code-engine/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!-- Add a description of module(s) in this repo -->
This module provisions the IBM Cloud Code Engine fully managed and serverless platform. It supports deployment of containerized workloads, including web apps, batch jobs, builds, config maps, bindings, domain mappings, or secrets. For more information, see [About Code Engine](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started)


<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-code-engine](#terraform-ibm-code-engine)
* [Submodules](./modules)
    * [app](./modules/app)
    * [binding](./modules/binding)
    * [build](./modules/build)
    * [config_map](./modules/config_map)
    * [domain_mapping](./modules/domain_mapping)
    * [job](./modules/job)
    * [project](./modules/project)
    * [secret](./modules/secret)
* [Examples](./examples)
    * [Apps example](./examples/apps)
    * [Jobs example](./examples/jobs)
* [Contributing](#contributing)
<!-- END OVERVIEW HOOK -->


<!--
If this repo contains any reference architectures, uncomment the heading below and links to them.
(Usually in the `/reference-architectures` directory.)
See "Reference architecture" in Authoring Guidelines in the public documentation at
https://terraform-ibm-modules.github.io/documentation/#/implementation-guidelines?id=reference-architecture
-->
<!-- ## Reference architectures -->


<!-- This heading should always match the name of the root level module (aka the repo name) -->
## terraform-ibm-code-engine

### Known limitations

Currently, IBM provider supports basic functionalities, such as create/delete/update code engine projects, apps, jobs, builds and etc.

Known limitations are:
- No support to create/delete/update code engine functions. https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5230
- No support to create/delete/update code engine subscriptions. https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5231
- Apply twice keeps on showing changes for `ibm_code_engine_app` and `ibm_code_engine_job` terraform resource https://github.com/IBM-Cloud/terraform-provider-ibm/issues/4719
- CLI/API service binding implementation/interface is different from terraform implementation. For example, CLI or UI code engine has a support to create access secret, service credential and all bindings automatically, while `code_engine_binding_instance` terraform resource requires that access secret exists before the binding is created. The second discrepancy between implementations is that terraform `code_engine_binding_instance` terraform resource requires `prefix` while using CLI or UI `prefix` is an optional parameter. https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5229
- Visibility for application can not be set. While CLI uses `--visibility=private` flag to set the visibility, terraform provider doesn't support it. https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5228
- Apply twice throws an error for `ibm_code_engine_secret` terraform resource https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5232
- Apply twice throws an error for `ibm_code_engine_app` terraform resource https://github.com/IBM-Cloud/terraform-provider-ibm/issues/6330

### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->
```hcl
module "code_engine" {
  source       = "terraform-ibm-modules/code-engine/ibm"
  version      = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  project_name = "your-project-name"
  apps         = {
                  "your-app-name-1" = {
                    image_reference = "container_registry_url"
                    run_env_variables = [{
                      type  = "literal"
                      name  = "env_name"
                      value = "env_value"
                      }]
                  },
                  "your-app-name-2" = {
                    image_reference = "container_registry_url"
                  }
                }
  jobs         = {
                  "your-job-name" = {
                    image_reference = "container_registry_url"
                    run_env_variables = [{
                      type  = "literal"
                      name  = "env_name"
                      value = "env_value"
                    }]
                  }
                }
  config_maps  = {
                  "your-config-name" = {
                    data = { "key_1" : "value_1", "key_2" : "value_2" }
                  }
                }
  secrets      = {
                  "your-secret-name" = {
                    format = "generic"
                    data   = { "key_1" : "value_1", "key_2" : "value_2" }
                  }
                }
  builds       = {
                  "your-build-name" = {
                    output_image  = "container_registry_url"
                    output_secret = "secret-name" # pragma: allowlist secret
                    source_url    = "https://github.com/IBM/CodeEngine"
                    strategy_type = "dockerfile"
                  }
                }
}
```

### Required IAM access policies

You need the following permissions to run this module.

- Account Management
    - **Resource Group** service
        - `Viewer` platform access
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

| Name | Source | Version |
|------|--------|---------|
| <a name="module_app"></a> [app](#module\_app) | ./modules/app | n/a |
| <a name="module_binding"></a> [binding](#module\_binding) | ./modules/binding | n/a |
| <a name="module_build"></a> [build](#module\_build) | ./modules/build | n/a |
| <a name="module_config_map"></a> [config\_map](#module\_config\_map) | ./modules/config_map | n/a |
| <a name="module_domain_mapping"></a> [domain\_mapping](#module\_domain\_mapping) | ./modules/domain_mapping | n/a |
| <a name="module_job"></a> [job](#module\_job) | ./modules/job | n/a |
| <a name="module_project"></a> [project](#module\_project) | ./modules/project | n/a |
| <a name="module_secret"></a> [secret](#module\_secret) | ./modules/secret | n/a |

### Resources

No resources.

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apps"></a> [apps](#input\_apps) | A map of code engine apps to be created. | <pre>map(object({<br/>    image_reference = string<br/>    image_secret    = optional(string)<br/>    run_env_variables = optional(list(object({<br/>      type      = optional(string)<br/>      name      = optional(string)<br/>      value     = optional(string)<br/>      prefix    = optional(string)<br/>      key       = optional(string)<br/>      reference = optional(string)<br/>    })))<br/>    run_volume_mounts = optional(list(object({<br/>      mount_path = string<br/>      reference  = string<br/>      name       = optional(string)<br/>      type       = string<br/>    })))<br/>    image_port                    = optional(number)<br/>    managed_domain_mappings       = optional(string)<br/>    run_arguments                 = optional(list(string))<br/>    run_as_user                   = optional(number)<br/>    run_commands                  = optional(list(string))<br/>    run_service_account           = optional(string)<br/>    scale_concurrency             = optional(number)<br/>    scale_concurrency_target      = optional(number)<br/>    scale_cpu_limit               = optional(string)<br/>    scale_ephemeral_storage_limit = optional(string)<br/>    scale_initial_instances       = optional(number)<br/>    scale_max_instances           = optional(number)<br/>    scale_memory_limit            = optional(string)<br/>    scale_min_instances           = optional(number)<br/>    scale_request_timeout         = optional(number)<br/>    scale_down_delay              = optional(number)<br/>  }))</pre> | `{}` | no |
| <a name="input_bindings"></a> [bindings](#input\_bindings) | A map of code engine bindings to be created. | <pre>map(object({<br/>    secret_name = string<br/>    components = list(object({<br/>      name          = string<br/>      resource_type = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_builds"></a> [builds](#input\_builds) | A map of code engine builds to be created. | <pre>map(object({<br/>    output_image               = string<br/>    output_secret              = string # pragma: allowlist secret<br/>    source_url                 = string<br/>    strategy_type              = string<br/>    ibmcloud_api_key           = string<br/>    existing_resource_group_id = string<br/>    source_context_dir         = optional(string)<br/>    source_revision            = optional(string)<br/>    source_secret              = optional(string)<br/>    source_type                = optional(string)<br/>    strategy_size              = optional(string)<br/>    strategy_spec_file         = optional(string)<br/>    timeout                    = optional(number)<br/>  }))</pre> | `{}` | no |
| <a name="input_cbr_rules"></a> [cbr\_rules](#input\_cbr\_rules) | The list of context-based restrictions rules to create. | <pre>list(object({<br/>    description = string<br/>    account_id  = string<br/>    rule_contexts = list(object({<br/>      attributes = optional(list(object({<br/>        name  = string<br/>        value = string<br/>    }))) }))<br/>    enforcement_mode = string<br/>    operations = optional(list(object({<br/>      api_types = list(object({<br/>        api_type_id = string<br/>      }))<br/>    })))<br/>  }))</pre> | `[]` | no |
| <a name="input_config_maps"></a> [config\_maps](#input\_config\_maps) | A map of code engine config maps to be created. | <pre>map(object({<br/>    data = map(string)<br/>  }))</pre> | `{}` | no |
| <a name="input_domain_mappings"></a> [domain\_mappings](#input\_domain\_mappings) | A map of code engine domain mappings to be created. | <pre>map(object({<br/>    tls_secret = string # pragma: allowlist secret<br/>    components = list(object({<br/>      name          = string<br/>      resource_type = string<br/>    }))<br/>  }))</pre> | `{}` | no |
| <a name="input_existing_project_id"></a> [existing\_project\_id](#input\_existing\_project\_id) | The ID of the existing project to which code engine resources will be added. It is required if var.project\_name is null. | `string` | `null` | no |
| <a name="input_existing_resource_group_id"></a> [existing\_resource\_group\_id](#input\_existing\_resource\_group\_id) | The ID of an existing resource group to provision resources in to. | `string` | `null` | no |
| <a name="input_ibmcloud_api_key"></a> [ibmcloud\_api\_key](#input\_ibmcloud\_api\_key) | The IBM Cloud API key. | `string` | `null` | no |
| <a name="input_jobs"></a> [jobs](#input\_jobs) | A map of code engine jobs to be created. | <pre>map(object({<br/>    image_reference = string<br/>    image_secret    = optional(string)<br/>    run_env_variables = optional(list(object({<br/>      type      = optional(string)<br/>      name      = optional(string)<br/>      value     = optional(string)<br/>      prefix    = optional(string)<br/>      key       = optional(string)<br/>      reference = optional(string)<br/>    })))<br/>    run_volume_mounts = optional(list(object({<br/>      mount_path = string<br/>      reference  = string<br/>      name       = optional(string)<br/>      type       = string<br/>    })))<br/>    run_arguments                 = optional(list(string))<br/>    run_as_user                   = optional(number)<br/>    run_commands                  = optional(list(string))<br/>    run_mode                      = optional(string)<br/>    run_service_account           = optional(string)<br/>    scale_array_spec              = optional(string)<br/>    scale_cpu_limit               = optional(string)<br/>    scale_ephemeral_storage_limit = optional(string)<br/>    scale_max_execution_time      = optional(number)<br/>    scale_memory_limit            = optional(string)<br/>    scale_retry_limit             = optional(number)<br/>  }))</pre> | `{}` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the project to which code engine resources will be added. It is required if var.existing\_project\_id is null. | `string` | `null` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | ID of the resource group to use when creating resources. | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | A map of code engine secrets to be created. | <pre>map(object({<br/>    format = string<br/>    data   = map(string)<br/>    # Issue with provider, service_access is not supported at the moment. https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5232<br/>    # service_access = optional(list(object({<br/>    #   resource_key = list(object({<br/>    #     id = optional(string)<br/>    #   }))<br/>    #   role = list(object({<br/>    #     crn = optional(string)<br/>    #   }))<br/>    #   service_instance = list(object({<br/>    #     id = optional(string)<br/>    #   }))<br/>    # })))<br/>  }))</pre> | `{}` | no |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_app"></a> [app](#output\_app) | Configuration of the created code engine app. |
| <a name="output_binding"></a> [binding](#output\_binding) | Configuration of the created code engine binding. |
| <a name="output_build"></a> [build](#output\_build) | Configuration of the created code engine build. |
| <a name="output_config_map"></a> [config\_map](#output\_config\_map) | Configuration of the created code engine config map. |
| <a name="output_domain_mapping"></a> [domain\_mapping](#output\_domain\_mapping) | Configuration of the created code engine domain maping. |
| <a name="output_job"></a> [job](#output\_job) | Configuration of the created code engine job. |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | ID of the created code engine project. |
| <a name="output_secret"></a> [secret](#output\_secret) | Configuration of the created code engine secret. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
