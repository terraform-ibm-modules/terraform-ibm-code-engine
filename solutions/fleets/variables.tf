########################################################################################################################
# Input variables
########################################################################################################################

variable "ibmcloud_api_key" {
  type        = string
  description = "The IBM Cloud API key."
  sensitive   = true
}

variable "provider_visibility" {
  description = "Set the visibility value for the IBM terraform provider. Supported values are `public`, `private`, `public-and-private`. [Learn more](https://registry.terraform.io/providers/IBM-Cloud/ibm/latest/docs/guides/custom-service-endpoints)."
  type        = string
  default     = "private"

  validation {
    condition     = contains(["public", "private", "public-and-private"], var.provider_visibility)
    error_message = "Invalid visibility option. Allowed values are 'public', 'private', or 'public-and-private'."
  }
}

variable "prefix" {
  type        = string
  nullable    = true
  description = "The prefix to be added to all resources created by this solution. To skip using a prefix, set this value to null or an empty string. The prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It should not exceed 16 characters, must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--'). Example: prod-0205-ce. [Learn more](https://terraform-ibm-modules.github.io/documentation/#/prefix.md)."

  validation {
    # - null and empty string is allowed
    # - Must not contain consecutive hyphens (--): length(regexall("--", var.prefix)) == 0
    # - Starts with a lowercase letter: [a-z]
    # - Contains only lowercase letters (a–z), digits (0–9), and hyphens (-)
    # - Must not end with a hyphen (-): [a-z0-9]
    condition = (var.prefix == null || var.prefix == "" ? true :
      alltrue([
        can(regex("^[a-z][-a-z0-9]*[a-z0-9]$", var.prefix)),
        length(regexall("--", var.prefix)) == 0
      ])
    )
    error_message = "Prefix must begin with a lowercase letter and may contain only lowercase letters, digits, and hyphens '-'. It must not end with a hyphen('-'), and cannot contain consecutive hyphens ('--')."
  }

  validation {
    # must not exceed 16 characters in length
    condition     = var.prefix == null || var.prefix == "" ? true : length(var.prefix) <= 16
    error_message = "Prefix must not exceed 16 characters."
  }
}

variable "region" {
  type        = string
  description = "The region in which to provision all resources created by this solution."
  default     = "us-south"
}

variable "existing_resource_group_name" {
  type        = string
  description = "The name of an existing resource group to provision the resources."
  default     = "Default"
}

variable "project_name" {
  description = "The name of the project to add the IBM Cloud Code Engine. If a prefix input variable is specified, the prefix is added to the name in the `<prefix>-<project_name>` format."
  type        = string
  default     = "ce-project"
}

variable "resource_tags" {
  type        = list(string)
  description = "Optional list of tags to add to the created resources."
  default     = []
}


##############################################################################
# CBR Rules
##############################################################################
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
  description = "The list of context-based restrictions rules to create.[Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-code-engine/blob/main/solutions/project/DA-cbr_rules.md)"
  default     = []
}


##############################################################################
# vpc
##############################################################################

variable "enable_logging" {
  description = "Whether to add support for cloud logs."
  type        = bool
  nullable    = false
  default     = false
}

variable "enable_monitoring" {
  description = "Whether to add support for cloud monitoring."
  type        = bool
  nullable    = false
  default     = false
}


variable "network_acls" {
  description = "List of network ACLs to create with VPC"
  type = list(
    object({
      name                         = string
      add_ibm_cloud_internal_rules = optional(bool)
      add_vpc_connectivity_rules   = optional(bool)
      prepend_ibm_rules            = optional(bool)
      rules = list(
        object({
          name        = string
          action      = string
          destination = string
          direction   = string
          source      = string
          tcp = optional(
            object({
              port_max        = optional(number)
              port_min        = optional(number)
              source_port_max = optional(number)
              source_port_min = optional(number)
            })
          )
          udp = optional(
            object({
              port_max        = optional(number)
              port_min        = optional(number)
              source_port_max = optional(number)
              source_port_min = optional(number)
            })
          )
          icmp = optional(
            object({
              type = optional(number)
              code = optional(number)
            })
          )
        })
      )
    })
  )
  default = [
    {
      name                         = "fleets-allow-all-acl"
      add_ibm_cloud_internal_rules = true
      add_vpc_connectivity_rules   = true
      prepend_ibm_rules            = true
      rules = [
        {
          name        = "allow-all-egress"
          action      = "allow"
          direction   = "outbound"
          source      = "0.0.0.0/0"
          destination = "0.0.0.0/0"
        },
        {
          name        = "allow-all-ingress"
          action      = "allow"
          direction   = "inbound"
          source      = "0.0.0.0/0"
          destination = "0.0.0.0/0"
        }
      ]
    }
  ]
}

variable "subnets" {
  description = "Map of zones to subnet configurations"
  type = map(list(object({
    name           = string
    cidr           = string
    public_gateway = bool
    acl_name       = string
  })))
  default = {
    zone-1 = [
      {
        name           = "fleet-subnet-a"
        cidr           = "10.10.10.0/24"
        public_gateway = true
        acl_name       = "fleets-allow-all-acl"
      }
    ]
  }
}
variable "ex_subnet_zone_list" {
  description = "List of subnets for the vpc. For each item in each array, a subnet will be created. Items can be either CIDR blocks or total ipv4 addresses. Public gateways will be enabled only in zones where a gateway has been created. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-landing-zone-vpc/blob/main/solutions/fully-configurable/DA-types.md#subnets-)."
  #
 type = list(object({
    cidr = optional(string)
    crn  = string
    id   = string
    name = string
    zone = string
  }))
  default = []

  # validation {
  #   condition     = alltrue([for key, value in var.ex_subnet_zone_list : value != null ? length([for subnet in value : subnet.public_gateway if subnet.public_gateway]) > 1 ? false : true : true])
  #   error_message = "var.subnets has more than one public gateway in a zone. Only one public gateway can be attached to a zone for the virtual private cloud."
  # }
}


variable "vpc_name" {
  type     = string
  nullable = true
  default  = null
}

variable "vpc_id" {
  type     = string
  nullable = true
  default  = null
}

# cos


variable "existing_cos_instance_crn" {
  type        = string
  nullable    = true
  description = "The CRN of an existing Cloud Object Storage instance. If a CRN is not specified, a new instance of Cloud Object Storage is created."
}

variable "cos_plan" {
  description = "The plan to use when Object Storage instances are created. Possible values are `standard` or `cos-one-rate-plan`. Required if `create_cos_instance` is set to `true`. [Learn more](https://cloud.ibm.com/docs/cloud-object-storage?topic=cloud-object-storage-provision)."
  type        = string
  default     = "standard"
  validation {
    condition     = contains(["standard", "cos-one-rate-plan"], var.cos_plan)
    error_message = "The value is not valid. Possible values are `standard` or `cos-one-rate-plan`."
  }
}


variable "cos_location" {
  description = "The location for the Object Storage instance. Required if `create_cos_instance` is set to `true`."
  type        = string
  default     = "global"
}

# variable "cos_instance_id" {
#   description = "The location for the Object Storage instance. Required if `create_cos_instance` is set to `true`."
#   type        = string
#   default     = "global"
# }

# variable "resource_keys" {
#   description = "The definition of the resource keys to generate. [Learn more](https://github.com/terraform-ibm-modules/terraform-ibm-cos/tree/main/solutions/instance/DA-types.md#resource-keys)."
#   type = list(any)
#   default = [  ]
# }

########################################################################################################################
# Cloud monitoring
########################################################################################################################

variable "cloud_monitoring_plan" {
  type        = string
  description = "The IBM Cloud Monitoring plan to provision. Available: lite, graduated-tier and graduated-tier-sysdig-secure-plus-monitor (available in region eu-fr2 only)"
  default     = "graduated-tier"
}

variable "existing_cloud_monitoring_crn" {
  type        = string
  nullable    = true
  description = "The CRN of existing cloud monitoring instance"
  default     = null
}


variable "cloud_monitoring_access_key" {
  type        = string
  nullable    = true
  description = "The access key of existing cloud monitoring instance"
  default     = null
}



########################################################################################################################
# Cloud logs
########################################################################################################################

variable "existing_cloud_logs_crn" {
  type        = string
  nullable    = true
  description = "The CRN of the existing cloud logs instance"
  default     = null
}

variable "cloud_logs_ingress_private_endpoint" {
  type        = string
  default     = null
  description = "The ingress private endpoint of the cloud logs instance"
}
