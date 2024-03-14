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
  default     = {}
}
