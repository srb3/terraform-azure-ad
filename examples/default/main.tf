provider "azuread" {
  tenant_id = var.azure_ad_tenant_id
}

module "azure_ad_app_kong_manager" {
  source        = "../../"
  display_name  = "kong-app-reg"
  redirect_uris = var.redirect_uris
  client_secret = var.client_secret
  users         = var.manager_users
  multi_user    = var.multi_user
}

locals {
  file_location = "${path.module}/example_scripts"
  create_service = templatefile("${path.module}/templates/create_service", {
    kong_admin_api = var.kong_admin_api
    kong_token     = var.kong_token
    workspace      = var.workspace
  })

  create_route = templatefile("${path.module}/templates/create_route", {
    kong_admin_api = var.kong_admin_api
    kong_token     = var.kong_token
    workspace      = var.workspace
  })

  create_oidc_plugin = templatefile("${path.module}/templates/create_oidc_plugin", {
    kong_admin_api = var.kong_admin_api
    kong_token     = var.kong_token
    issuer         = module.azure_ad_app_kong_manager.issuer
    client_id      = module.azure_ad_app_kong_manager.client_id
    client_secret  = module.azure_ad_app_kong_manager.client_secret
    workspace      = var.workspace
  })

  create_app_reg_plugin = templatefile("${path.module}/templates/create_app_reg_plugin", {
    kong_admin_api = var.kong_admin_api
    kong_token     = var.kong_token
    workspace      = var.workspace
  })

  get_token = templatefile("${path.module}/templates/get_token", {
    token_endpoint = module.azure_ad_app_kong_manager.token_endpoint
    client_id      = module.azure_ad_app_kong_manager.client_id
    client_secret  = module.azure_ad_app_kong_manager.client_secret
  })

  consume_service = templatefile("${path.module}/templates/consume_service", {
    token_endpoint   = module.azure_ad_app_kong_manager.token_endpoint
    client_id        = module.azure_ad_app_kong_manager.client_id
    client_secret    = module.azure_ad_app_kong_manager.client_secret
    service_endpoint = var.service_endpoint
  })
}

resource "local_file" "create_service" {
  content         = local.create_service
  filename        = "${local.file_location}/create_service.sh"
  file_permission = "0744"
}

resource "local_file" "create_route" {
  content         = local.create_route
  filename        = "${local.file_location}/create_route.sh"
  file_permission = "0744"
}

resource "local_file" "create_oidc_plugin" {
  content         = local.create_oidc_plugin
  filename        = "${local.file_location}/create_oidc_plugin.sh"
  file_permission = "0744"
}

resource "local_file" "create_app_reg_plugin" {
  content         = local.create_app_reg_plugin
  filename        = "${local.file_location}/create_app_reg_plugin.sh"
  file_permission = "0744"
}

resource "local_file" "get_token" {
  content         = local.get_token
  filename        = "${local.file_location}/get_token.sh"
  file_permission = "0744"
}

resource "local_file" "consume_service" {
  content         = local.consume_service
  filename        = "${local.file_location}/consume_service.sh"
  file_permission = "0744"
}
