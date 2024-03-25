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

variable "image_secret" {
  description = "The name of the image registry access secret."
  type        = string
  default     = null
}

variable "run_env_variables" {
  description = "References to config maps, secrets or a literal values that are exposed as environment variables within the running application."
  type = list(object({
    type      = optional(string)
    name      = optional(string)
    value     = optional(string)
    prefix    = optional(string)
    key       = optional(string)
    reference = optional(string)
  }))
  default = []
}

variable "run_volume_mounts" {
  description = "Optional mounts of config maps or a secrets."
  type = list(object({
    mount_path = string
    reference  = string
    name       = optional(string)
    value      = optional(string)
  }))
  default = []
}

variable "run_arguments" {
  description = "Arguments for the app that are passed to start the container."
  type        = list(string)
  default     = []
}

variable "run_as_user" {
  description = "The user ID (UID) to run the app."
  type        = number
  default     = null
}

variable "run_commands" {
  description = "Commands for the app that are passed to start the container."
  type        = list(string)
  default     = []
}

variable "run_mode" {
  description = "Commands for the app that are passed to start the container."
  type        = string
  default     = "task"
}

variable "run_service_account" {
  description = "The name of the service account."
  type        = string
  default     = "default"
}

variable "scale_array_spec" {
  description = "Define a custom set of array indices as comma-separated list containing single values and hyphen-separated ranges like 5,12-14,23,27."
  type        = string
  default     = null
}

variable "scale_cpu_limit" {
  description = "The number of CPU set for the instance of the app."
  type        = string
  default     = "1"
}

variable "scale_ephemeral_storage_limit" {
  description = "The amount of ephemeral storage to set for the instance of the app."
  type        = string
  default     = "400M"
}

variable "scale_max_execution_time" {
  description = "The maximum execution time in seconds for runs of the job."
  type        = number
  default     = 7200
}

variable "scale_memory_limit" {
  description = "The amount of memory set for the instance of the app."
  type        = string
  default     = "4G"
}

variable "scale_retry_limit" {
  description = "The number of times to rerun an instance of the job before the job is marked as failed."
  type        = number
  default     = 3
}
