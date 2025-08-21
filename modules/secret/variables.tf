########################################################################################################################
# Input Variables
########################################################################################################################

variable "project_id" {
  description = "The ID of the project where secret will be created."
  type        = string
}
variable "name" {
  description = "The name of the secret."
  type        = string
}

variable "format" {
  description = "Specify the format of the secret."
  type        = string
}

variable "data" {
  description = "Data container that allows to specify config parameters and their values as a key-value map."
  type        = map(string)
  sensitive   = true
  default     = {}
}

# Issue with provider, service_access is not supported at the moment. https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5232
variable "service_access" {
  description = "Properties for Service Access Secrets."
  type = list(object({
    resource_key = list(object({
      id = optional(string)
    }))
    role = list(object({
      crn = optional(string)
    }))
    service_instance = list(object({
      id = optional(string)
    }))
  }))
  default = []
}
