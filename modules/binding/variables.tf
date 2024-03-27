########################################################################################################################
# Input Variables
########################################################################################################################

variable "project_id" {
  description = "The ID of the project where binding will be created."
  type        = string
}

variable "prefix" {
  description = "Value that is set as prefix in the component that is bound."
  type        = string
}

variable "secret_name" {
  description = "The service access secret that is binding to a component."
  type        = string
}

variable "components" {
  description = "A reference to another component."
  type = list(object({
    name          = string
    resource_type = string
  }))
}
