########################################################################################################################
# Input Variables
########################################################################################################################

variable "project_id" {
  description = "The ID of the project where job will be created."
  type        = string
}

variable "name" {
  description = "The name of the job."
  type        = string
}


variable "image_reference" {
  description = "The name of the image that is used for this job."
  type        = string
}

variable "run_env_variables" {
  description = "Optional references to config maps, secrets or a literal values that are exposed as environment variables within the running application."
  type = list(object({
    type = string
    name = string
  value = string }))
  default = []
}
