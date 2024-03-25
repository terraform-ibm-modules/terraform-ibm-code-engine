########################################################################################################################
# Input Variables
########################################################################################################################

variable "project_id" {
  description = "The ID of the project where domain mapping will be created."
  type        = string
}

variable "name" {
  description = "The name of the domain mapping."
  type        = string
}

variable "components" {
  description = "A reference to another component."
  type = list(object({
    name          = string
    resource_type = string
  }))
}

variable "tls_secret" {
  description = "The name of the TLS secret that holds the certificate and private key of this domain mapping."
  type        = string
}
