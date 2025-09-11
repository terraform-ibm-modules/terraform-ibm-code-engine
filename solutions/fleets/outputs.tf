# ########################################################################################################################
# # Outputs
# ########################################################################################################################

output "resource_group_name" {
  description = "Name of the resource group."
  value       = module.resource_group.resource_group_name
}

# output "cos_buckets" {
#   value = module.cos_buckets.buckets[local.taskstore_bucket_name].s3_endpoint_private
# }
# output "project_name" {
#   description = "Name of the project."
#   value       = module.project.name
# }

# output "project_id" {
#   description = "ID of the created code engine project."
#   value       = module.project.project_id
# }

# output "secret" {
#   description = "Configuration of the created code engine secret."
#   value       = module.secret
# }

# output "build" {
#   description = "Configuration of the created code engine build."
#   value       = module.build
# }

# output "app" {
#   description = "Configuration of the created code engine app."
#   value       = module.app
# }


# output "cre" {
#   value     = module.cos.resource_keys["${local.prefix}-hmac-key"].credentials["apikey"]
#   sensitive = true
# }
