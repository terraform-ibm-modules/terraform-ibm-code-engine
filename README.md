<!-- Update the title -->
# Terraform Modules Template Project

<!--
Update status and "latest release" badges:
  1. For the status options, see https://terraform-ibm-modules.github.io/documentation/#/badge-status
  2. Update the "latest release" badge to point to the correct module's repo. Replace "terraform-ibm-module-template" in two places.
-->
[![Incubating (Not yet consumable)](https://img.shields.io/badge/status-Incubating%20(Not%20yet%20consumable)-red)](https://terraform-ibm-modules.github.io/documentation/#/badge-status)
[![latest release](https://img.shields.io/github/v/release/terraform-ibm-modules/terraform-ibm-module-template?logo=GitHub&sort=semver)](https://github.com/terraform-ibm-modules/terraform-ibm-module-template/releases/latest)
[![pre-commit](https://img.shields.io/badge/pre--commit-enabled-brightgreen?logo=pre-commit&logoColor=white)](https://github.com/pre-commit/pre-commit)
[![Renovate enabled](https://img.shields.io/badge/renovate-enabled-brightgreen.svg)](https://renovatebot.com/)
[![semantic-release](https://img.shields.io/badge/%20%20%F0%9F%93%A6%F0%9F%9A%80-semantic--release-e10079.svg)](https://github.com/semantic-release/semantic-release)

<!-- Add a description of module(s) in this repo -->
TODO: Replace me with description of the module(s) in this repo


<!-- Below content is automatically populated via pre-commit hook -->
<!-- BEGIN OVERVIEW HOOK -->
## Overview
* [terraform-ibm-code-engine](#terraform-ibm-code-engine)
* [Examples](./examples)
    * [Basic example](./examples/basic)
    * [Complete example](./examples/complete)
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
| <a name="requirement_ibm"></a> [ibm](#requirement\_ibm) | >= 1.58.1, <2.0.0 |

### Modules

No modules.

### Resources

| Name | Type |
|------|------|
| [ibm_code_engine_app.ce_app](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_app) | resource |
| [ibm_code_engine_config_map.ce_config_map](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_config_map) | resource |
| [ibm_code_engine_job.ce_job](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_job) | resource |
| [ibm_code_engine_project.ce_project](https://registry.terraform.io/providers/ibm-cloud/ibm/latest/docs/resources/code_engine_project) | resource |

### Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_apps"></a> [apps](#input\_apps) | n/a | <pre>map(object({<br>    test = string<br>  }))</pre> | <pre>{<br>  "ap_1": {<br>    "test": "asas"<br>  },<br>  "ap_2": {<br>    "test": "asas"<br>  }<br>}</pre> | no |
| <a name="input_code_engine"></a> [code\_engine](#input\_code\_engine) | n/a | <pre>map(object({<br>    apps = optional(list(object({<br>      name            = string<br>      image_reference = string<br>    }))),<br>    jobs = optional(list(object({<br>      name            = string<br>      image_reference = string<br><br>    })))<br>  }))</pre> | <pre>{<br>  "project_11": {<br>    "apps": [<br>      {<br>        "image_reference": "icr.io/codeengine/helloworld",<br>        "name": "app-name1"<br>      },<br>      {<br>        "image_reference": "icr.io/codeengine/helloworld",<br>        "name": "app-name2"<br>      }<br>    ],<br>    "jobs": [<br>      {<br>        "image_reference": "icr.io/codeengine/helloworld",<br>        "name": "jobs-1"<br>      }<br>    ]<br>  },<br>  "project_22": {<br>    "apps": [<br>      {<br>        "image_reference": "icr.io/codeengine/helloworld",<br>        "name": "app-name1"<br>      }<br>    ]<br>  }<br>}</pre> | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | ce-pro-and | `string` | `"ce-pro-and"` | no |
| <a name="input_region"></a> [region](#input\_region) | IBM Cloud region where all resources will be deployed | `string` | `"us-south"` | no |
| <a name="input_resource_group_id"></a> [resource\_group\_id](#input\_resource\_group\_id) | ID of resource group to use when creating the VPC and PAG | `string` | n/a | yes |

### Outputs

| Name | Description |
|------|-------------|
| <a name="output_myoutput"></a> [myoutput](#output\_myoutput) | Description of my output |
| <a name="output_test"></a> [test](#output\_test) | n/a |
<!-- END OF PRE-COMMIT-TERRAFORM DOCS HOOK -->

<!-- Leave this section as is so that your module has a link to local development environment set up steps for contributors to follow -->
## Contributing

You can report issues and request features for this module in GitHub issues in the module repo. See [Report an issue or request a feature](https://github.com/terraform-ibm-modules/.github/blob/main/.github/SUPPORT.md).

To set up your local development environment, see [Local development setup](https://terraform-ibm-modules.github.io/documentation/#/local-dev-setup) in the project documentation.
