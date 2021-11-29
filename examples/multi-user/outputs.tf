output "client_id" {
  value = module.azure_ad_app_kong_manager.client_id
}

output "client_secret" {
  sensitive = true
  value     = module.azure_ad_app_kong_manager.client_secret
}

output "issuer" {
  value = module.azure_ad_app_kong_manager.issuer
}

output "metadata" {
  value = module.azure_ad_app_kong_manager.metadata-url
}

output "test_user" {
  value = module.azure_ad_app_kong_manager.test_user
}

output "test_password" {
  value = module.azure_ad_app_kong_manager.test_password
}

output "test_workspace" {
  value = module.azure_ad_app_kong_manager.test_workspace
}
