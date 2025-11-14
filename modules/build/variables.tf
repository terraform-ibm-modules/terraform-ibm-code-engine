########################################################################################################################
# Input Variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key."
  sensitive   = true
}

variable "prefix" {
  type        = string
  description = "Prefix appended to the container registry namespace and registry secret if created."
  default     = null
}

variable "existing_resource_group_id" {
  description = "The ID of an existing resource group where build will be provisioned. This must be the same resource group in which the code engine project was created."
  type        = string
}

variable "project_id" {
  description = "The ID of the project where build will be created."
  type        = string
}

variable "name" {
  description = "The name of the build."
  type        = string
}

variable "output_image" {
  description = <<EOT
A container image can be identified by a container image reference with the following structure: registry / namespace / repository:tag. [Learn more](https://cloud.ibm.com/docs/codeengine?topic=codeengine-getting-started).

If not provided, the value will be derived from the 'container_registry_namespace' input variable, which must not be null in that case.
EOT
  type        = string
  default     = null
}

variable "region" {
  type        = string
  description = "The region in which to provision the build. This must be the same region in which the code engine project was created."
  nullable    = false
  default     = "us-south"
}

variable "source_context_dir" {
  description = "The directory in the repository that contains the buildpacks file or the Dockerfile."
  type        = string
  default     = null
}

variable "source_revision" {
  description = "Commit, tag, or branch in the source repository to pull."
  type        = string
  default     = null
}

variable "source_secret" {
  description = "The name of the secret that is used access the repository source. If the var.source_type value is `local`, this input must be omitted."
  type        = string
  default     = null
}

variable "source_type" {
  description = "Specifies the type of source to determine if your build source is in a repository or based on local source code. If the value is `local`, then 'source_secret' input must be omitted."
  type        = string
  default     = null

  validation {
    condition     = contains(["git", "local"], var.source_type)
    error_message = "'source_type' can be 'git' or 'local' only"
  }

  validation {
    condition     = var.source_type != "local" || var.source_secret == null
    error_message = "If 'source_type' is 'local', 'source_secret' must not be provided."
  }
}

variable "source_url" {
  description = "The URL of the code repository."
  type        = string
}

variable "strategy_size" {
  description = "The size for the build, which determines the amount of resources used."
  type        = string
  default     = null
}

variable "strategy_spec_file" {
  description = "The path to the specification file that is used for build strategies for building an image."
  type        = string
  default     = null
}

variable "strategy_type" {
  description = "The strategy to use for building the image."
  type        = string
  nullable    = false
  default     = "dockerfile"
}

variable "timeout" {
  description = "The maximum amount of time, in seconds, that can pass before the build must succeed or fail."
  type        = number
  default     = 600
}

##############################################################################
# Container Registry
##############################################################################

variable "container_registry_namespace" {
  description = "The name of the namespace to create in IBM Cloud Container Registry for organizing container images. Must be set if 'output_image' is not set. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<container_registry_namespace>` format."
  type        = string
  default     = null

  validation {
    condition = (
      (var.output_image != null && var.container_registry_namespace == null) ||
      (var.output_image == null && var.container_registry_namespace != null)
    )
    error_message = "Exactly one of 'output_image' or 'container_registry_namespace' must be set (not both or neither)."
  }
}

variable "output_secret" {
  description = <<EOT
The name of the Code Engine secret that contains an API key to access the IBM Cloud Container Registry.
The API key stored in this secret must have push permissions for the specified container registry namespace.
If this secret is not provided, a Code Engine secret named `<prefix>-<registry-access-secret>` will be created automatically. Its value will be taken from 'container_registry_api_key' if set, otherwise from 'ibmcloud_api_key'.
EOT
  type        = string
  default     = null

  validation {
    condition     = var.output_secret == null || var.container_registry_api_key == null
    error_message = "'output_secret' and 'container_registry_api_key' cannot both be set. Provide only one."
  }
}

variable "container_registry_api_key" {
  type        = string
  description = "The API key for the container registry in the target account. This is only used if 'output_secret' is not set and a new registry secret needs to be created. If not provided, the IBM Cloud API key (ibmcloud_api_key) will be used instead."
  sensitive   = true
  default     = null
}
