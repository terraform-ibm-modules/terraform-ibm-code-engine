locals {
  prefix       = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
  project_name = "${local.prefix}${var.project_name}"
}

########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.2.1"
  existing_resource_group_name = var.existing_resource_group_name
}

########################################################################################################################
# Cloud Object Storage
########################################################################################################################
locals {
  taskstore_bucket_name = "${local.prefix}taskstore"
  input_bucket_name     = "${local.prefix}input"
  output_bucket_name    = "${local.prefix}output"

  # bucket

  # module.cos_buckets.buckets["andrejfleet-output"]
  output_bucket_crn = module.cos_buckets.buckets[local.output_bucket_name].bucket_crn

  cos_key_name = "${local.prefix}-hmac-key"

  cos_instance_guid = var.existing_cos_instance_crn != null ? module.existing_cos_crn_parser.service_instance : null
  # cos_account_id    = var.existing_cos_instance_crn != null ? module.existing_cos_crn_parser.account_id : null

}

module "existing_cos_crn_parser" {
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = var.existing_cos_instance_crn
}

module "cos" {
  # count = var.existing_cos_instance_crn == null ? 1 : 0
  source  = "terraform-ibm-modules/cos/ibm"
  version = "10.2.13"
  # create_cos_instance = var.existing_cos_instance_crn != null ? false : true
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  cos_instance_name = "${local.prefix}cos"
  create_cos_bucket = false
  cos_plan          = var.cos_plan
  cos_location      = var.cos_location
  resource_keys = [{
    name                      = local.cos_key_name
    generate_hmac_credentials = true
    role                      = "Writer"
  }]

}
# {
#                   "dependency_input": "prefix",
#                   "value": [{
#                     name                      : "key-name"
#                     generate_hmac_credentials : true
#                     role                      : "Writer"
#                   }]
#                 },

resource "ibm_resource_key" "cos_hmac_key" {
  name                 = local.cos_key_name
  role                 = "Writer" # Or "Reader", "Manager", etc.
  resource_instance_id = var.existing_cos_instance_crn

  parameters = {
    "HMAC" = true
  }
}

module "cos_buckets" {
  source  = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version = "10.2.13"

  bucket_configs = [
    {
      bucket_name            = local.taskstore_bucket_name
      kms_encryption_enabled = false
      resource_instance_id   = var.existing_cos_instance_crn
      region_location        = var.region
      add_bucket_name_suffix = false
    },
    {
      bucket_name            = local.input_bucket_name
      kms_encryption_enabled = false
      resource_instance_id   = var.existing_cos_instance_crn
      region_location        = var.region
      add_bucket_name_suffix = false
    },
    {
      bucket_name            = local.output_bucket_name
      kms_encryption_enabled = false
      resource_instance_id   = var.existing_cos_instance_crn
      region_location        = var.region
      add_bucket_name_suffix = false
    },
  ]
}

# custom bucket lifecycle
resource "ibm_cos_bucket_lifecycle_configuration" "output_bucket_lifecycle" {
  bucket_crn      = local.output_bucket_crn
  bucket_location = var.region

  lifecycle_rule {
    rule_id = "simulation-results"
    status  = "enable"

    filter {
      prefix = "simulation/ticker"
    }

    expiration {
      days = 1
    }
  }

  lifecycle_rule {
    rule_id = "inferencing results"
    status  = "enable"

    filter {
      prefix = "inverencing/inferencing"
    }

    expiration {
      days = 1
    }
  }

  lifecycle_rule {
    rule_id = "docling results"
    status  = "enable"

    filter {
      prefix = "docling/docling"
    }

    expiration {
      days = 1
    }
  }

  lifecycle_rule {
    rule_id = "wordcount results"
    status  = "enable"

    filter {
      prefix = "wordcount/wordcount"
    }

    expiration {
      days = 1
    }
  }
}


########################################################################################################################
# Persistent Data Store
########################################################################################################################

resource "null_resource" "fleet_task_store_pds" {
  depends_on = [module.secret, resource.null_resource.fleet_cos_secret, resource.ibm_iam_authorization_policy.codeengine_to_cos]
  provisioner "local-exec" {
    command = <<EOT
      echo

      ibmcloud login -r "${var.region}" -g "${module.resource_group.resource_group_name}" --apikey "${var.ibmcloud_api_key}"
      ibmcloud ce project select --name ${module.project.name}
      ibmcloud ce pds create --name fleet-task-store \
        --cos-bucket-name ${local.taskstore_bucket_name} \
        --cos-bucket-location ${var.region} \
        --cos-access-secret "fleet-cos-secret"
    EOT
  }
}

resource "null_resource" "fleet_input_store_pds" {
  depends_on = [module.secret, resource.null_resource.fleet_cos_secret, resource.ibm_iam_authorization_policy.codeengine_to_cos]
  provisioner "local-exec" {
    command = <<EOT
      ibmcloud login -r "${var.region}" -g "${module.resource_group.resource_group_name}" --apikey "${var.ibmcloud_api_key}"
      ibmcloud ce project select --name ${module.project.name}
      ibmcloud ce pds create --name fleet-input-store \
        --cos-bucket-name ${local.input_bucket_name} \
        --cos-bucket-location ${var.region} \
        --cos-access-secret "fleet-cos-secret"
    EOT
  }
}

resource "null_resource" "fleet_output_store_pds" {
  depends_on = [module.secret, resource.null_resource.fleet_cos_secret, resource.ibm_iam_authorization_policy.codeengine_to_cos]
  provisioner "local-exec" {
    command = <<EOT
      ibmcloud login -r "${var.region}" -g "${module.resource_group.resource_group_name}" --apikey "${var.ibmcloud_api_key}"
      ibmcloud ce project select --name ${module.project.name}
      ibmcloud ce pds create --name fleet-output-store \
        --cos-bucket-name ${local.output_bucket_name} \
        --cos-bucket-location ${var.region} \
        --cos-access-secret "fleet-cos-secret"
    EOT
  }
}


resource "ibm_iam_authorization_policy" "codeengine_to_cos" {
  source_service_name         = "codeengine"
  source_resource_instance_id = module.project.project_id

  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = local.cos_instance_guid


  roles = ["Notifications Manager"]
}


########################################################################################################################
# VPC
########################################################################################################################

module "vpc" {
  source            = "terraform-ibm-modules/landing-zone-vpc/ibm"
  version           = "8.2.0"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  name              = "vpc"
  prefix            = local.prefix
  tags              = var.resource_tags

  enable_vpc_flow_logs = false

  use_public_gateways = {
    zone-1 = true
    zone-2 = false
    zone-3 = false
  }

  subnets = {
    zone-1 = [
      {
        name           = "${local.prefix}subnet"
        cidr           = "10.10.10.0/24"
        public_gateway = true
        acl_name       = "${local.prefix}acl"
      }
    ]
  }
  clean_default_sg_acl = true
  network_acls = [
    {
      name                         = "${local.prefix}acl"
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

# data "ibm_is_vpc" "vpc" {
#   depends_on = [module.vpc] # Explicit "depends_on" here to wait for the full subnet creations
#   identifier = module.vpc.vpc_id
# }

module "fleet_sg" {
  source  = "terraform-ibm-modules/security-group/ibm"
  version = "2.7.0"

  security_group_name = "${local.prefix}sg"
  vpc_id              = module.vpc.vpc_id

  security_group_rules = [
    # {
    #   name        = "allow-all-inbound-from-self"
    #   direction   = "inbound"
    #   remote      = "0.0.0.0/0"
    #   # tcp         = { port_min = 0, port_max = 65535 }
    # },
    {
      name      = "allow-all-outbound"
      direction = "outbound"
      remote    = "0.0.0.0/0"
      # tcp         = { port_min = 0, port_max = 65535 }
    }
  ]
}


resource "ibm_is_security_group_rule" "example" {
  group     = module.fleet_sg.security_group_id
  direction = "inbound"
  remote    = module.fleet_sg.security_group_id
}

########################################################################################################################
# VPE
########################################################################################################################

locals {
  cloud_services = concat(
    var.existing_cloud_logs_crn != null ? [
      {
        crn                          = var.existing_cloud_logs_crn
        vpe_name                     = "${local.prefix}icl-vpegw"
        allow_dns_resolution_binding = false
      }
    ] : [],
    var.existing_cloud_monitoring_crn != null ? [
      {
        crn                          = var.existing_cloud_monitoring_crn
        vpe_name                     = "${local.prefix}sysdig-vpegw"
        allow_dns_resolution_binding = false
      }
    ] : []
  )
}

module "vpe_logging" {
  count   = length(local.cloud_services) > 0 ? 1 : 0
  source  = "terraform-ibm-modules/vpe-gateway/ibm"
  version = "4.7.6"

  region            = var.region
  prefix            = "${local.prefix}log"
  resource_group_id = module.resource_group.resource_group_id
  vpc_id            = module.vpc.vpc_id
  vpc_name          = module.vpc.vpc_name

  subnet_zone_list = [
    {
      id   = ([for s in module.vpc.vpc_data.subnets : s.id if s.name == "${local.prefix}-vpc-${local.prefix}subnet"])[0]
      name = "${local.prefix}subnet"
      zone = "zone-1"
    }
  ]

  security_group_ids = [module.fleet_sg.security_group_id]

  cloud_service_by_crn = local.cloud_services

  service_endpoints = "private"
}

########################################################################################################################
# Cloud logs
########################################################################################################################

locals {
  icl_name        = "${local.prefix}icl"
  cloud_logs_guid = var.existing_cloud_logs_crn != null ? module.existing_cloud_logs_crn[0].service_instance : null

}

module "existing_cloud_logs_crn" {
  count   = var.existing_cloud_logs_crn != null ? 1 : 0
  source  = "terraform-ibm-modules/common-utilities/ibm//modules/crn-parser"
  version = "1.2.0"
  crn     = var.existing_cloud_logs_crn
}

module "cloud_logs" {
  count             = var.enable_logging ? 1 : 0
  depends_on        = [module.cos_buckets]
  source            = "terraform-ibm-modules/cloud-logs/ibm"
  version           = "1.6.21"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region

  # data_storage = {
  #   logs_data = {
  #     enabled = false
  #     # enabled         = true
  #     # bucket_crn      = module.cos_buckets.buckets[local.taskstore_bucket_name].bucket_crn
  #     # bucket_endpoint = module.cos_buckets.buckets[local.taskstore_bucket_name].s3_endpoint_public
  #   }
  #   metrics_data = {
  #     enabled = false
  #   }
  # }


  instance_name = local.icl_name
  # cloud_logs_provision        = true
  # cloud_logs_plan             = "standard"
  # cloud_logs_service_endpoints = "private"
}

resource "ibm_iam_service_id" "logs_service_id" {
  count       = var.existing_cloud_logs_crn != null ? 1 : 0
  name        = "${local.icl_name}-svc-id"
  description = "Service ID to ingest into IBM Cloud Logs instance"
}

# Create IAM Service Policy granting "Sender" role to this service ID on the Cloud Logs instance
resource "ibm_iam_service_policy" "logs_policy" {
  count          = var.existing_cloud_logs_crn != null ? 1 : 0
  iam_service_id = ibm_iam_service_id.logs_service_id[0].id
  roles          = ["Sender"]
  description    = "Policy for ServiceID to send logs to IBM Cloud Logs instance"

  resources {
    service              = "logs"
    resource_instance_id = local.cloud_logs_guid # Cloud Logs instance GUID
  }
}


# Create an API key for this service ID (to use for ingestion authentication)
# resource "ibm_iam_api_key" "cloud_logs_ingestion_apikey" {
#   name         = "logs-ingestion-key"
#   iam_id = ibm_iam_service_id.logs_service_id[0].iam_id
#   description  = "API key to ingest logs into IBM Cloud Logs instance ${module.cloud_logs[0].name}"
# }

########################################################################################################################
# Cloud monitoring
########################################################################################################################
locals {
  monitoring_name     = "${local.prefix}-sysdig"
  monitoring_key_name = "${local.prefix}-sysdig-key"
}

module "cloud_monitoring" {
  count             = var.enable_monitoring ? 1 : 0
  source            = "terraform-ibm-modules/cloud-monitoring/ibm"
  version           = "1.7.1"
  region            = var.region
  resource_group_id = module.resource_group.resource_group_id
  instance_name     = local.monitoring_name
  plan              = var.cloud_monitoring_plan
  service_endpoints = "public-and-private"
  # enable_platform_metrics = false
  manager_key_name = local.monitoring_key_name
}


########################################################################################################################
# Code Engine Project
########################################################################################################################

module "project" {
  source            = "../../modules/project"
  name              = local.project_name
  resource_group_id = module.resource_group.resource_group_id
  cbr_rules         = var.cbr_rules
}

##############################################################################
# Code Engine Secret
##############################################################################
locals {
  fleet_cos_secret_name      = "fleet-cos-secret"
  fleet_registry_secret_name = "fleet-registry-secret"
  fleet_registry_secret = {
    (local.fleet_registry_secret_name) = {
      format = "registry"
      "data" = {
        password = var.ibmcloud_api_key,
        username = "iamapikey",
        server   = "us.icr.io"
      }
    }
  }

  codeengine_fleet_defaults_name = "codeengine-fleet-defaults"
  codeengine_fleet_defaults = {
    (local.codeengine_fleet_defaults_name) = {
      format = "generic"
      data = merge(
        {
          pool_subnet_crn_1          = data.ibm_is_subnet.example.crn
          pool_security_group_crns_1 = data.ibm_is_security_group.example.crn
        },
        var.existing_cloud_logs_crn != null ? {
          logging_ingress_endpoint = var.cloud_logs_ingress_private_endpoint
          logging_sender_api_key   = var.ibmcloud_api_key
          logging_level_agent      = "debug"
          logging_level_worker     = "debug"
        } : {},
        var.existing_cloud_monitoring_crn != null ? {
          monitoring_ingestion_region = var.region
          monitoring_ingestion_key    = var.cloud_monitoring_access_key
        } : {}
      )
    }
  }

  secrets = merge(local.fleet_registry_secret, local.codeengine_fleet_defaults)
}

# creation of hmac secret is not supported by code engine provider
# terraform_data
resource "null_resource" "fleet_cos_secret" {
  provisioner "local-exec" {
    command = <<EOT
      ibmcloud login -r "${var.region}" -g "${module.resource_group.resource_group_name}" --apikey "${var.ibmcloud_api_key}"
      ibmcloud ce project select --name ${module.project.name}
      ibmcloud ce secret create --name ${local.fleet_cos_secret_name} \
      --format hmac \
      --access-key-id ${ibm_resource_key.cos_hmac_key.credentials["cos_hmac_keys.access_key_id"]}  \
      --secret-access-key ${ibm_resource_key.cos_hmac_key.credentials["cos_hmac_keys.secret_access_key"]}
    EOT
  }
}


data "ibm_is_security_group" "example" {
  depends_on = [module.fleet_sg]
  name       = "${local.prefix}sg"
}

data "ibm_is_subnet" "example" {
  identifier = ([for s in module.vpc.vpc_data.subnets : s.id if s.name == "${local.prefix}-vpc-${local.prefix}subnet"])[0]
}

module "secret" {
  source     = "../../modules/secret"
  for_each   = nonsensitive(local.secrets)
  project_id = module.project.project_id
  name       = each.key
  data       = each.value.data
  format     = each.value.format
  # Issue with provider, service_access is not supported at the moment. https://github.com/IBM-Cloud/terraform-provider-ibm/issues/5232
  # service_access = each.value.service_access
}
