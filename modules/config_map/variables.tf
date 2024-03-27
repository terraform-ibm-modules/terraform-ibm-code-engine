########################################################################################################################
# Input Variables
########################################################################################################################

variable "project_id" {
  description = "The ID of the project where config map will be created."
  type        = string
}

variable "name" {
  description = "The name of the config map."
  type        = string
}

variable "data" {
  description = "The key-value pair for the config map."
  type        = map(string)
  default     = {}
}
