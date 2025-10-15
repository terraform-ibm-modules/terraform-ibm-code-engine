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
    operations = optional(list(object({
      api_types = list(object({
        api_type_id = string
      }))
    })))
  }))
  description = "The list of context-based restrictions rules to create."
  default     = []
  validation {
    condition     = length(var.cbr_rules) <= 1
    error_message = "There should only be one rule."
  }
}
