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

variable "cbr_rules" {
  type = list(object({
    description = string
    account_id  = string
    rule_contexts = list(object({
      attributes = optional(list(object({
        name  = string
        value = string
    }))) }))
    enforcement_mode = string
    tags = optional(list(object({
      name  = string
      value = string
    })))
  }))
  description = "(Optional, list) List of CBR rules to create"
  default     = []
  # Validation happens in the rule module
}
