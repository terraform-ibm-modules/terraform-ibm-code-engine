##############################################################################
# terraform-ibm-code-engine
#
# Create Code Engine project
##############################################################################

resource "ibm_code_engine_project" "ce_project" {
  name              = var.name
  resource_group_id = var.resource_group_id
}

##############################################################################
# Context Based Restrictions
##############################################################################

module "cbr_rules" {
  count            = length(var.cbr_rules) > 0 ? length(var.cbr_rules) : 0
  source           = "terraform-ibm-modules/cbr/ibm//modules/cbr-rule-module"
  version          = "1.34.0"
  rule_description = var.cbr_rules[count.index].description
  enforcement_mode = var.cbr_rules[count.index].enforcement_mode
  rule_contexts    = var.cbr_rules[count.index].rule_contexts
  operations       = var.cbr_rules[count.index].operations
  resources = [{
    attributes = [
      {
        name     = "accountId"
        value    = var.cbr_rules[count.index].account_id
        operator = "stringEquals"
      },
      {
        name     = "serviceInstance"
        value    = ibm_code_engine_project.ce_project.id
        operator = "stringEquals"
      },
      {
        name     = "serviceName"
        value    = "codeengine"
        operator = "stringEquals"
      }
    ]
  }]
}
