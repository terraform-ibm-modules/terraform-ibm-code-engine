########################################################################################################################
# Input Variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key."
  sensitive   = true
}

variable "existing_resource_group_id" {
  description = "The ID of an existing resource group to provision resources in to."
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
  description = "The name of the image."
  type        = string
  default     = null
}

variable "output_secret" {
  description = "The secret that is required to access the image registry."
  type        = string
}

variable "region" {
  type        = string
  description = "The region in which to provision the build."
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
  description = "The name of the secret that is used access the repository source. If the var.source_type value is `local`, this field must be omitted."
  type        = string
  default     = null
}

variable "source_type" {
  description = "Specifies the type of source to determine if your build source is in a repository or based on local source code."
  type        = string
  default     = null
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
}

variable "timeout" {
  description = "The maximum amount of time, in seconds, that can pass before the build must succeed or fail."
  type        = number
  default     = 600
}
