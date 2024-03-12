<!-- Update the title -->
# Terraform Modules Template Project

<!--
Update status and "latest release" badges:
  1. For the status options, see https://terraform-ibm-modules.github.io/documentation/#/badge-status
  2. Update the "latest release" badge to point to the correct module's repo. Replace "terraform-ibm-module-template" in two places.
-->
[![Stable (With quality checks)](https://img.shields.io/badge/Status-Stable%20(With%20quality%20checks)-green)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-code-engine?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-code-engine/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!-- Add a description of module(s) in this repo -->
This module provisions the IBM Cloud Code Engine fully managed and serverless platform. It supports to deploy containerized workloads, including web apps, batch jobs, builds, config maps, bindings, domain mappings, or secrets. For more information, see [About Code Engine](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started)


<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-code-engine](#terraform-ibm-code-engine)
* [Examples](./examples)
    * [Basic example](./examples/basic)
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
## terraform-ibm-module-template

### Usage

<!--
Add an example of the use of the module in the following code block.

Use real values instead of "var.<var_name>" or other placeholder values
unless real values don't help users know what to change.
-->

```hcl
module "code_engine" {
  source      = "terraform-ibm-modules/code-engine/ibm"
  version     = "X.X.X" # Replace "X.X.X" with a release version to lock into a specific release
  code_engine = {
    "project-name" = {
      apps = [{
        name            = "app-name"
        image_reference = "container_registry_url"
      }],
      jobs = [{
        name              = "job-name"
        image_reference   = "container_registry_url"
        run_env_variables = [{
          type  = "literal"
          name  = "env_name"
          value = "env_value"
        }]
      }],
      config_maps = [{
        name = "config-map-name"
        data = { "key" : "value" }
      }],
      secrets = [{
        name   = "secret-name"
        format = "generic"
        data   = { "key" : "value" }
      }],
      builds = [{
        name          = "BUILD-NAME"
        output_image  = "container_registry_url"
        output_secret = "output-secret-name" # pragma: allowlist secret
        source_url    = "domain"
        strategy_type = "dockerfile"
      }]
    }
  }
}
```

### Required IAM access policies

<!-- PERMISSIONS REQUIRED TO RUN MODULE
If this module requires permissions, uncomment the following block and update
the sample permissions, following the format.
Replace the sample Account and IBM Cloud service names and roles with the
information in the console at
Manage > Access (IAM) > Access groups > Access policies.
-->

<!--
You need the following permissions to run this module.

- Account Management
    - **Sample Account Service** service
        - `Editor` platform access
        - `Manager` service access
    - IAM Services
        - **Sample Cloud Service** service
            - `Administrator` platform access
-->

<!-- NO PERMISSIONS FOR MODULE
If no permissions are required for the module, uncomment the following
statement instead the previous block.
-->

<!-- No permissions are needed to run this module.-->


<!-- Below content is automatically populated via pre-commit hook -->
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
| [ibm_code_engine_binding.ce_binding](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_binding) | resource |
| [ibm_code_engine_build.ce_build](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_build) | resource |
| [ibm_code_engine_config_map.ce_config_map](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_config_map) | resource |
| [ibm_code_engine_domain_mapping.ce_domain_mapping](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_domain_mapping) | resource |
| [ibm_code_engine_job.ce_job](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_job) | resource |
| [ibm_code_engine_project.ce_project](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_project) | resource |
| [ibm_code_engine_secret.code_engine_secret_instance](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_secret) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_code_engine"></a> [code\_engine](#input\_code\_engine) | A map describing code engine resources to be created. | <pre>map(object({<br>    apps = optional(list(object({<br>      name            = string<br>      image_reference = string<br>      run_env_variables = optional(list(object({<br>        type  = string<br>        name  = string<br>        value = string<br>      })))<br>    }))),<br>    jobs = optional(list(object({<br>      name            = string<br>      image_reference = string<br>      run_env_variables = optional(list(object({<br>        type  = string<br>        name  = string<br>        value = string<br>      })))<br>    }))),<br>    config_maps = optional(list(object({<br>      name = string<br>      data = optional(map(string))<br>    }))),<br>    secrets = optional(list(object({<br>      name   = string<br>      format = string<br>      data   = optional(map(string))<br>    }))),<br>    builds = optional(list(object({<br>      name          = string<br>      output_image  = string<br>      output_secret = string # pragma: allowlist secret<br>      source_url    = string<br>      strategy_type = string<br>    })))<br>    bindings = optional(list(object({<br>      prefix      = string<br>      secret_name = string # pragma: allowlist secret<br>      components = list(object({<br>        name          = string<br>        resource_type = string<br>      }))<br>    })))<br>    domain_mappings = optional(list(object({<br>      name = string<br>      components = list(object({<br>        name          = string<br>        resource_type = string<br>      }))<br>      tls_secret = string<br>    })))<br>  }))</pre> | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | ID of resource group to use when creating resources | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_apps"></a> [apps](#output\_apps) | Created code engine apps. |
| <a name="output_bindings"></a> [bindings](#output\_bindings) | Created code engine bindings. |
| <a name="output_builds"></a> [builds](#output\_builds) | Created code engine builds. |
| <a name="output_config_maps"></a> [config\_maps](#output\_config\_maps) | Created code engine config\_maps. |
| <a name="output_domain_mappings"></a> [domain\_mappings](#output\_domain\_mappings) | Created code engine domain\_mappings. |
| <a name="output_jobs"></a> [jobs](#output\_jobs) | Created code engine jobs. |
| <a name="output_projects"></a> [projects](#output\_projects) | Created code engine projects. |
| <a name="output_secrets"></a> [secrets](#output\_secrets) | Created code engine secrets. |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
