########################################################################################################################
# Input Variables
########################################################################################################################

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
}

variable "output_secret" {
  description = "The secret that is required to access the image registry."
  type        = string
}

variable "source_url" {
  description = "The URL of the code repository."
  type        = string
}

variable "strategy_type" {
  description = "Specifies the type of source to determine if your build source is in a repository or based on local source code."
  type        = string
}
