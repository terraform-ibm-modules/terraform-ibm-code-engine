<!-- Update the title -->
# Terraform Code Engine Module

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
| <a name="input_apps"></a> [apps](#input\_apps) | A map of code engine apps to be created. | <pre>map(object({<br>    image_reference = string<br>    run_env_variables = optional(list(object({<br>      type  = string<br>      name  = string<br>      value = string<br>    })))<br>  }))</pre> | `{}` | no |
| <a name="input_bindings"></a> [bindings](#input\_bindings) | A map of code engine bindings to be created. | <pre>map(object({<br>    secret_name = string<br>    components = list(object({<br>      name          = string<br>      resource_type = string<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_builds"></a> [builds](#input\_builds) | A map of code engine builds to be created. | <pre>map(object({<br>    output_image  = string<br>    output_secret = string # pragma: allowlist secret<br>    source_url    = string<br>    strategy_type = string<br>  }))</pre> | `{}` | no |
| <a name="input_config_maps"></a> [config\_maps](#input\_config\_maps) | A map of code engine config maps to be created. | <pre>map(object({<br>    data = map(string)<br>  }))</pre> | `{}` | no |
| <a name="input_domain_mappings"></a> [domain\_mappings](#input\_domain\_mappings) | A map of code engine domain mappings to be created. | <pre>map(object({<br>    tls_secret = string # pragma: allowlist secret<br>    components = list(object({<br>      name          = string<br>      resource_type = string<br>    }))<br>  }))</pre> | `{}` | no |
| <a name="input_jobs"></a> [jobs](#input\_jobs) | A map of code engine jobs to be created. | <pre>map(object({<br>    image_reference = string<br>    run_env_variables = optional(list(object({<br>      type  = string<br>      name  = string<br>      value = string<br>    })))<br>  }))</pre> | `{}` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | The name of the project to which code engine resources will be added. | `string` | n/a | yes |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | ID of the resource group to use when creating resources. | `string` | n/a | yes |
| <a name="input_secrets"></a> [secrets](#input\_secrets) | A map of code engine secrets to be created. | <pre>map(object({<br>    format = string<br>    data   = map(string)<br>  }))</pre> | `{}` | no |

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
