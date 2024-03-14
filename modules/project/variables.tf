########################################################################################################################
# Input Variables
########################################################################################################################

variable "resource_group_id" {
  description = "ID of resource group to use when creating resources"
  type        = string
}

variable "name" {
  description = "The name of the project."
  type        = string
}
