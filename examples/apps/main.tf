########################################################################################################################
# Resource group
########################################################################################################################

module "resource_group" {
  source  = "terraform-ibm-modules/resource-group/ibm"
  version = "1.4.7"
  # if an existing resource group is not set (null) create a new one using prefix
  resource_group_name          = var.resource_group == null ? "${var.prefix}-resource-group" : null
  existing_resource_group_name = var.resource_group
}

########################################################################################################################
# Secrets Manager resources
########################################################################################################################

locals {
  sm_guid   = var.existing_sm_instance_guid == null ? ibm_resource_instance.secrets_manager[0].guid : var.existing_sm_instance_guid
  sm_region = var.existing_sm_instance_region == null ? var.region : var.existing_sm_instance_region

  # Certificate issuance is rate limited by domain, by default pick different domains to avoid rate limits during testing
  cert_common_name = var.existing_cert_common_name == null ? "${var.prefix}.goldeneye.dev.cloud.ibm.com" : var.existing_cert_common_name
  cert_secret_id   = var.existing_cert_secret_id == null ? resource.ibm_sm_public_certificate.secrets_manager_public_certificate[0].secret_id : var.existing_cert_secret_id

}

# Create a new SM instance if not using an existing one
resource "ibm_resource_instance" "secrets_manager" {
  count             = var.existing_sm_instance_guid == null ? 1 : 0
  name              = "${var.prefix}-sm-instance"
  service           = "secrets-manager"
  plan              = var.sm_service_plan
  location          = local.sm_region
  resource_group_id = module.resource_group.resource_group_id
  timeouts {
    create = "20m" # Extending provisioning time to 20 minutes
  }
  provider = ibm.ibm-sm
}

# Configure public cert engine if provisioning a new SM instance
module "secrets_manager_public_cert_engine" {
  depends_on = [ibm_resource_instance.secrets_manager]
  count      = var.existing_sm_instance_guid == null ? 1 : 0
  source     = "terraform-ibm-modules/secrets-manager-public-cert-engine/ibm"
  version    = "1.6.17"
  providers = {
    ibm              = ibm.ibm-sm
    ibm.secret-store = ibm.ibm-sm
  }
  secrets_manager_guid                      = local.sm_guid
  region                                    = local.sm_region
  internet_services_crn                     = var.cis_id
  dns_config_name                           = var.dns_provider_name
  ca_config_name                            = var.ca_name
  acme_letsencrypt_private_key              = var.acme_letsencrypt_private_key
  private_key_secrets_manager_instance_guid = var.private_key_secrets_manager_instance_guid
  private_key_secrets_manager_secret_id     = var.private_key_secrets_manager_secret_id
  private_key_secrets_manager_region        = var.private_key_secrets_manager_region
}

# Create a secret group to place the certificate in
module "secrets_manager_group" {
  count                    = var.existing_cert_secret_id == null ? 1 : 0
  source                   = "terraform-ibm-modules/secrets-manager-secret-group/ibm"
  version                  = "1.3.37"
  region                   = local.sm_region
  secrets_manager_guid     = local.sm_guid
  secret_group_name        = "${var.prefix}-certificates-secret-group"
  secret_group_description = "secret group used for private certificates"
  providers = {
    ibm = ibm.ibm-sm
  }
}

resource "ibm_sm_public_certificate" "secrets_manager_public_certificate" {
  depends_on = [module.secrets_manager_public_cert_engine]
  count      = var.existing_cert_secret_id == null ? 1 : 0

  instance_id     = local.sm_guid
  region          = local.sm_region
  name            = local.cert_common_name
  description     = "Certificate for ${local.cert_common_name} domain"
  ca              = var.ca_name
  dns             = var.dns_provider_name
  common_name     = local.cert_common_name
  secret_group_id = module.secrets_manager_group[0].secret_group_id
  rotation {
    auto_rotate = true
  }
}

data "ibm_sm_public_certificate" "public_certificate" {
  depends_on  = [resource.ibm_sm_public_certificate.secrets_manager_public_certificate]
  instance_id = local.sm_guid
  region      = local.sm_region
  secret_id   = local.cert_secret_id
}

##############################################################################
# Get Cloud Account ID
##############################################################################

data "ibm_iam_account_settings" "iam_account_settings" {
}

##############################################################################
# VPC
##############################################################################
resource "ibm_is_vpc" "example_vpc" {
  name           = "${var.prefix}-vpc"
  resource_group = module.resource_group.resource_group_id
  tags           = var.resource_tags
}

resource "ibm_is_subnet" "testacc_subnet" {
  name                     = "${var.prefix}-subnet"
  vpc                      = ibm_is_vpc.example_vpc.id
  zone                     = "${var.region}-1"
  total_ipv4_address_count = 256
  resource_group           = module.resource_group.resource_group_id
}

##############################################################################
# Create CBR Zone
##############################################################################

module "cbr_vpc_zone" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.35.10"
  name             = "${var.prefix}-VPC-network-zone"
  zone_description = "CBR Network zone representing VPC"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type  = "vpc",
    value = ibm_is_vpc.example_vpc.crn
  }]
}

module "cbr_zone_schematics" {
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-zone-module"
  version          = "1.35.10"
  name             = "${var.prefix}-schematics-zone"
  zone_description = "CBR Network zone containing Schematics"
  account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
  addresses = [{
    type = "serviceRef",
    ref = {
      account_id   = data.ibm_iam_account_settings.iam_account_settings.account_id
      service_name = "schematics"
    }
  }]
}

########################################################################################################################
# Code Engine instance
########################################################################################################################

module "code_engine" {
  depends_on        = [resource.ibm_sm_public_certificate.secrets_manager_public_certificate]
  source            = "git::https://github.com/terraform-ibm-modules/terraform-ibm-code-engine.git?ref=bin-install"
  resource_group_id = module.resource_group.resource_group_id
  project_name      = "${var.prefix}-project"
  cbr_rules = [
    {
      description      = "${var.prefix}-code engine access"
      enforcement_mode = "enabled"
      account_id       = data.ibm_iam_account_settings.iam_account_settings.account_id
      rule_contexts = [{
        attributes = [
          {
            "name" : "endpointType",
            "value" : "public"
          },
          {
            name  = "networkZoneId"
            value = module.cbr_vpc_zone.zone_id
        }]
        },
        {
          attributes = [
            {
              name  = "networkZoneId"
              value = module.cbr_zone_schematics.zone_id
          }]
      }]
      operations = [{
        api_types = [{
          api_type_id = "crn:v1:bluemix:public:context-based-restrictions::::platform-api-type:"
        }]
      }]
    }
  ]

  apps = {
    "${var.prefix}-app" = {
      image_reference = "icr.io/codeengine/helloworld"
      run_env_variables = [{
        type  = "literal"
        name  = "name_1"
        value = "value_1"
        },
        {
          type  = "literal"
          name  = "name_2"
          value = "value_2"
      }]
      scale_cpu_limit               = "4",
      scale_memory_limit            = "32G"
      scale_ephemeral_storage_limit = "300M"
      managed_domain_mappings       = "local_private"
    }
    "${var.prefix}-app2" = {
      image_reference = "icr.io/codeengine/helloworld"
    }
  }
  config_maps = {
    "${var.prefix}-cm" = {
      data = { "key_1" : "value_1", "key_2" : "value_2" }
    }
  }
  secrets = {
    "${var.prefix}-tls" = {
      format = "tls"
      data = {
        "tls_cert" = format("%s%s", data.ibm_sm_public_certificate.public_certificate.certificate, data.ibm_sm_public_certificate.public_certificate.intermediate)
        "tls_key"  = data.ibm_sm_public_certificate.public_certificate.private_key
      }
    }
  }
  domain_mappings = {
    # tflint-ignore: terraform_deprecated_interpolation
    "${local.cert_common_name}" = {
      components = [{
        name          = "${var.prefix}-app"
        resource_type = "app_v2"
      }]
      tls_secret = "${var.prefix}-tls"
    }
  }
}
