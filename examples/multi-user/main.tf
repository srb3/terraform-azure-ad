provider "azuread" {
  tenant_id = var.azure_ad_tenant_id
}

module "azure_ad_app_kong_manager" {
  source        = "../../"
  display_name  = "kong-manager"
  redirect_uris = var.redirect_uris
  client_secret = var.client_secret
  users         = var.manager_users
  multi_user    = var.multi_user
}
