locals {
  prefix                   = var.prefix != null ? trimspace(var.prefix) != "" ? "${var.prefix}-" : "" : ""
  code_engine_project_name = "${local.prefix}${var.code_engine_project_name}"
}

########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source                       = "terraform-ibm-modules/resource-group/ibm"
  version                      = "1.3.0"
  existing_resource_group_name = var.existing_resource_group_name
}

########################################################################################################################
# Cloud Object Storage
########################################################################################################################
locals {
  taskstore_bucket_name = "${local.prefix}taskstore"
  input_bucket_name     = "${local.prefix}input"
  output_bucket_name    = "${local.prefix}output"
  output_bucket_crn     = module.cos_buckets.buckets[local.output_bucket_name].bucket_crn
  cos_key_name          = "${local.prefix}-hmac-key"
}

module "cos" {
  source              = "terraform-ibm-modules/cos/ibm"
  version             = "10.2.13"
  create_cos_instance = true
  resource_group_id   = module.resource_group.resource_group_id
  region              = var.region
  cos_instance_name   = "${local.prefix}cos"
  create_cos_bucket   = false
  cos_plan            = var.cos_plan
  cos_location        = "global"
  resource_keys = [{
    name                      = local.cos_key_name
    generate_hmac_credentials = true
    role                      = "Writer"
  }]
}

module "cos_buckets" {
  source  = "terraform-ibm-modules/cos/ibm//modules/buckets"
  version = "10.2.13"

  bucket_configs = [
    {
      bucket_name            = local.taskstore_bucket_name
      kms_encryption_enabled = false
      resource_instance_id   = module.cos.cos_instance_crn
      region_location        = var.region
      add_bucket_name_suffix = false
    },
    {
      bucket_name            = local.input_bucket_name
      kms_encryption_enabled = false
      resource_instance_id   = module.cos.cos_instance_crn
      region_location        = var.region
      add_bucket_name_suffix = false
    },
    {
      bucket_name            = local.output_bucket_name
      kms_encryption_enabled = false
      resource_instance_id   = module.cos.cos_instance_crn
      region_location        = var.region
      add_bucket_name_suffix = false
    }
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

locals {
  bucket_store_map = {
    (local.taskstore_bucket_name) = "fleet-task-store"
    (local.input_bucket_name)     = "fleet-input-store"
    (local.output_bucket_name)    = "fleet-output-store"
  }
}


resource "terraform_data" "create_pds" {
  depends_on = [module.project, null_resource.fleet_cos_secret, module.cos_buckets]
  provisioner "local-exec" {
    interpreter = ["/bin/bash"]
    command     = "../../scripts/persistent_data_store.sh"
    environment = {
      IBMCLOUD_API_KEY  = var.ibmcloud_api_key
      RESOURCE_GROUP_ID = module.resource_group.resource_group_id
      CE_PROJECT_NAME   = module.project.name
      REGION            = var.region
      BUCKET_STORE_MAP  = jsonencode(local.bucket_store_map)
      COS_ACCESS_SECRET = local.fleet_cos_secret_name
    }
  }
}

resource "ibm_iam_authorization_policy" "codeengine_to_cos" {
  source_service_name         = "codeengine"
  source_resource_instance_id = module.project.project_id
  target_service_name         = "cloud-object-storage"
  target_resource_instance_id = module.cos.cos_instance_guid
  roles                       = ["Notifications Manager"]
}

########################################################################################################################
# VPC
########################################################################################################################
locals {
  vpc_id = data.ibm_is_vpc.vpc.id
}

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
    zone-2 = var.vpc_zones >= 2 ? true : false
    zone-3 = var.vpc_zones >= 3 ? true : false
  }

  subnets = merge(
    {
      zone-1 = [
        {
          name           = "${local.prefix}subnet-a"
          cidr           = "10.10.10.0/24"
          public_gateway = true
          acl_name       = "${local.prefix}acl"
        }
    ] },
    var.vpc_zones >= 2 ? {
      zone-2 = [
        {
          name           = "${local.prefix}subnet-b"
          cidr           = "10.20.10.0/24"
          public_gateway = true
          acl_name       = "${local.prefix}acl"
        }
      ]
    } : {},
    var.vpc_zones >= 3 ? {
      zone-3 = [
        {
          name           = "${local.prefix}subnet-c"
          cidr           = "10.30.10.0/24"
          public_gateway = true
          acl_name       = "${local.prefix}acl"
        }
      ]
    } : {}
  )
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

data "ibm_is_vpc" "vpc" {
  depends_on = [module.vpc] # Explicit "depends_on" here to wait for the full subnet creations
  identifier = module.vpc.vpc_id
}

module "fleet_sg" {
  source  = "terraform-ibm-modules/security-group/ibm"
  version = "2.7.0"

  security_group_name = "${local.prefix}sg"
  vpc_id              = local.vpc_id

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
    var.enable_cloud_logs ? [
      {
        crn                          = module.cloud_logs[0].crn
        vpe_name                     = "${local.prefix}icl-vpegw"
        allow_dns_resolution_binding = false
      }
    ] : [],
    local.enable_cloud_monitoring ? [
      {
        crn                          = module.cloud_monitoring[0].crn
        vpe_name                     = "${local.prefix}sysdig-vpegw"
        allow_dns_resolution_binding = false
      }
    ] : []
  )
}

module "vpe_logging" {
  count                = length(local.cloud_services) > 0 ? 1 : 0
  source               = "terraform-ibm-modules/vpe-gateway/ibm"
  version              = "4.7.6"
  region               = var.region
  prefix               = "${local.prefix}log"
  resource_group_id    = module.resource_group.resource_group_id
  vpc_id               = local.vpc_id
  vpc_name             = data.ibm_is_vpc.vpc.name
  subnet_zone_list     = [for subnet in module.vpc.subnet_zone_list : { id = subnet.id, name = subnet.name, zone = subnet.zone, cidr = subnet.cidr }]
  security_group_ids   = [module.fleet_sg.security_group_id]
  cloud_service_by_crn = local.cloud_services
  service_endpoints    = "private"
}

########################################################################################################################
# Cloud logs
########################################################################################################################

locals {
  icl_name = "${local.prefix}icl"
}

module "cloud_logs" {
  count             = var.enable_cloud_logs ? 1 : 0
  depends_on        = [module.cos_buckets]
  source            = "terraform-ibm-modules/cloud-logs/ibm"
  version           = "1.6.21"
  resource_group_id = module.resource_group.resource_group_id
  region            = var.region
  instance_name     = local.icl_name
}

resource "ibm_iam_service_id" "logs_service_id" {
  count       = var.enable_cloud_logs ? 1 : 0
  name        = "${local.icl_name}-svc-id"
  description = "Service ID to ingest into IBM Cloud Logs instance ${module.cloud_logs[0].name}"
}

# Create IAM Service Policy granting "Sender" role to this service ID on the Cloud Logs instance
resource "ibm_iam_service_policy" "logs_policy" {
  count          = var.enable_cloud_logs ? 1 : 0
  iam_service_id = ibm_iam_service_id.logs_service_id[0].id
  roles          = ["Sender"]
  description    = "Policy for ServiceID to send logs to IBM Cloud Logs instance"

  resources {
    service              = "logs"
    resource_instance_id = module.cloud_logs[0].guid # Cloud Logs instance GUID
  }
}

########################################################################################################################
# Cloud monitoring
########################################################################################################################
locals {
  enable_cloud_monitoring = var.cloud_monitoring_plan == "none" ? false : true
  monitoring_name         = "${local.prefix}-sysdig"
  monitoring_key_name     = "${local.prefix}-sysdig-key"
}

module "cloud_monitoring" {
  count                   = local.enable_cloud_monitoring ? 1 : 0
  source                  = "terraform-ibm-modules/cloud-monitoring/ibm"
  version                 = "1.7.1"
  region                  = var.region
  resource_group_id       = module.resource_group.resource_group_id
  instance_name           = local.monitoring_name
  plan                    = var.cloud_monitoring_plan
  service_endpoints       = "public-and-private"
  enable_platform_metrics = false
  manager_key_name        = local.monitoring_key_name
}


########################################################################################################################
# Code Engine Project
########################################################################################################################

module "project" {
  source            = "../../modules/project"
  name              = local.code_engine_project_name
  resource_group_id = module.resource_group.resource_group_id
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
          for idx, subnet in module.vpc.subnet_zone_list :
          "pool_subnet_crn_${idx + 1}" => subnet.crn
        },
        {
          pool_security_group_crns_1 = data.ibm_is_security_group.example.crn
        },
        var.enable_cloud_logs ? {
          logging_ingress_endpoint = module.cloud_logs[0].ingress_private_endpoint
          logging_sender_api_key   = var.ibmcloud_api_key
          logging_level_agent      = "debug"
          logging_level_worker     = "debug"
        } : {},
        local.enable_cloud_monitoring ? {
          monitoring_ingestion_region = var.region
          monitoring_ingestion_key    = module.cloud_monitoring[0].access_key
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
      --access-key-id ${module.cos.resource_keys[local.cos_key_name].credentials["cos_hmac_keys.access_key_id"]}  \
      --secret-access-key ${module.cos.resource_keys[local.cos_key_name].credentials["cos_hmac_keys.secret_access_key"]}
    EOT
  }
}


data "ibm_is_security_group" "example" {
  depends_on = [module.fleet_sg]
  name       = "${local.prefix}sg"
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
