##############################################################################
# terraform-ibm-code-engine
#
# Create Code Engine build
##############################################################################

resource "ibm_code_engine_build" "ce_build" {
  project_id         = var.project_id
  name               = var.name
  output_image       = var.output_image
  output_secret      = var.output_secret
  source_url         = var.source_url
  source_context_dir = var.source_context_dir
  source_revision    = var.source_revision
  source_secret      = var.source_secret
  source_type        = var.source_type
  strategy_type      = var.strategy_type
  strategy_size      = var.strategy_size
  strategy_spec_file = var.strategy_spec_file
  timeout            = var.timeout
}

data "ibm_code_engine_project" "code_engine_project" {
  project_id = var.project_id
}

resource "terraform_data" "run_build" {
  depends_on = [ibm_code_engine_build.ce_build]

  provisioner "local-exec" {
    interpreter = ["/bin/bash", "-c"]
    command     = "${path.module}/scripts/build-run.sh"
    environment = {
      IBMCLOUD_API_KEY  = var.ibmcloud_api_key
      RESOURCE_GROUP_ID = var.existing_resource_group_id
      CE_PROJECT_NAME   = data.ibm_code_engine_project.code_engine_project.name
      REGION            = var.region
      BUILD_NAME        = ibm_code_engine_build.ce_build.name
    }
  }
}
