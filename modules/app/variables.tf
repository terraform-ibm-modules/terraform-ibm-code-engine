########################################################################################################################
# Input Variables
########################################################################################################################

variable "project_id" {
  description = "The ID of the project where app will be created."
  type        = string
}

variable "name" {
  description = "The name of the app."
  type        = string
}

variable "image_reference" {
  description = "The name of the image that is used for the app."
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
    type       = string
  }))
  default = []
}

variable "image_port" {
  description = "The port which is used to connect to the port that is exposed by the container image."
  type        = number
  default     = 8080
}

variable "managed_domain_mappings" {
  description = "Define which of the system managed domain mappings will be setup for the application. Valid values are 'local_public', 'local_private' and 'local'."
  type        = string
  default     = null
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

variable "run_service_account" {
  description = "The name of the service account."
  type        = string
  default     = "default"
}

variable "scale_concurrency" {
  description = "The maximum number of requests that can be processed concurrently per instance."
  type        = number
  default     = 100
}

variable "scale_concurrency_target" {
  description = "The threshold of concurrent requests per instance at which one or more additional instances are created."
  type        = number
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

variable "scale_initial_instances" {
  description = "The initial number of instances that are created upon app creation or app update."
  type        = number
  default     = 1
}

variable "scale_max_instances" {
  description = "The maximum number of instances for this app."
  type        = number
  default     = 10
}

variable "scale_memory_limit" {
  description = "The amount of memory set for the instance of the app."
  type        = string
  default     = "4G"
}

variable "scale_min_instances" {
  description = "The minimum number of instances for this app.  If you set this value to 0, the app will scale down to zero, if not hit by any request for some time."
  type        = number
  default     = 0
}

variable "scale_request_timeout" {
  description = "The amount of time in seconds that is allowed for a running app to respond to a request."
  type        = number
  default     = 300
}
