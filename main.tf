# We do not have the correct permisions
# to create users in the Kong AD account, so we
# have to make do with using the user account
# of the person who runs this code
data "azuread_user" "this-user" {
  count               = var.multi_user ? 0 : 1
  user_principal_name = local.users.0
}

data "azuread_client_config" "current" {}

locals {
  base        = "https://login.microsoftonline.com"
  base_alt    = "https://sts.windows.net"
  tenant      = "${local.base}/${data.azuread_client_config.current.tenant_id}"
  tenant_alt  = "${local.base_alt}/${data.azuread_client_config.current.tenant_id}"
  issuer      = "${local.tenant}/v2.0"
  issuer_alt  = "${local.tenant_alt}/v2.0"
  meta        = "${local.issuer}/.well-known/openid-configuration"
  meta_alt    = "${local.issuer_alt}/.well-known/openid-configuration"
  user_ids    = var.multi_user ? azuread_user.this-user : { (data.azuread_user.this-user.0.id) = { "id" = data.azuread_user.this-user.0.id } }
  app_role_id = tolist(azuread_application.this-application.app_role).0.id
  #app_role_debug = azuread_application.this-application.app_role
  app_role_debug = { for x in azuread_application.this-application.app_role : x.value => {
    id = x.id
    }
  }
  sp_id = azuread_service_principal.this.id
  users = distinct(flatten([for k, v in var.users :
    v.email
  ]))

  groups = distinct(flatten([for k, v in var.users :
    [for x in v.groups :
      x
    ]
  ]))
  user_groups = flatten([for k, v in azuread_user.this-user :
    [for x in var.users[k].groups :
      "${v.id}~${local.app_role_debug[x].id}"
    ]
  ])
}

resource "random_uuid" "app_roles" {
  count = length(local.groups)
}

resource "azuread_user" "this-user" {
  for_each            = var.multi_user ? var.users : {}
  user_principal_name = each.value.email
  display_name        = each.key
  given_name          = each.value.first_name
  surname             = each.value.last_name
  password            = each.value.password
}

########### Groups ###############################

#locals {
#  user_group_app_ids = flatten([for k, v in azuread_user.this-user :
#    [for x in var.users[k].groups :
#      "${v.id}~${azuread_group.this-group[x].id}"
#    ]
#  ])
#}

#resource "azuread_group" "this-group" {
#  for_each     = var.multi_user ? { for x in local.groups : x => { "name" = x } } : {}
#  display_name = each.key
#}

############ User + group assignment #############

#resource "azuread_group_member" "this-group-membership" {
#  count            = var.multi_user ? length(local.user_group_app_ids) : 0
#  member_object_id = split("~", local.user_group_app_ids[count.index])[0]
#  group_object_id  = split("~", local.user_group_app_ids[count.index])[1]
#  depends_on       = [azuread_group.this-group, azuread_user.this-user]
#}

# Creating our application for openid connect
resource "azuread_application" "this-application" {
  display_name            = var.display_name
  identifier_uris         = var.identifier_uris
  owners                  = [data.azuread_client_config.current.object_id]
  sign_in_audience        = var.sign_in_audience
  group_membership_claims = [var.group_membership_claims]
  dynamic "app_role" {
    for_each = local.groups
    content {
      allowed_member_types = ["User", "Application"]
      description          = app_role.value
      display_name         = app_role.value
      enabled              = true
      id                   = random_uuid.app_roles[index(local.groups, app_role.value)].id
      value                = app_role.value
    }
  }
  api {
    requested_access_token_version = var.requested_access_token_version
    dynamic "oauth2_permission_scope" {
      for_each = var.set_scopes ? var.scopes : []
      content {
        admin_consent_description  = oauth2_permission_scope.value.admin_consent_description
        admin_consent_display_name = oauth2_permission_scope.value.admin_consent_display_name
        enabled                    = oauth2_permission_scope.value.enabled
        id                         = oauth2_permission_scope.value.id
        type                       = oauth2_permission_scope.value.type
        user_consent_description   = oauth2_permission_scope.value.user_consent_description
        user_consent_display_name  = oauth2_permission_scope.value.user_consent_display_name
        value                      = oauth2_permission_scope.value.value
      }
    }
  }

  web {
    redirect_uris = var.redirect_uris
    implicit_grant {
      access_token_issuance_enabled = false
    }
  }
  required_resource_access {
    # https://www.shawntabrizi.com/aad/common-microsoft-resources-azure-active-directory/
    # Note: 00000003-0000-0000-c000-000000000000 id for Microsoft Graph https://graph.microsoft.com
    resource_app_id = "00000003-0000-0000-c000-000000000000"
    # az ad sp show --id 00000003-0000-0000-c000-000000000000 --query "oauth2Permissions[?value=='User.Read']"
    resource_access {
      id   = "e1fe6dd8-ba31-4d61-89e7-88639da4683d"
      type = "Scope"
    }
  }
}

# We create a service principal for our
# application
resource "azuread_service_principal" "this" {
  application_id               = azuread_application.this-application.application_id
  app_role_assignment_required = false

  tags = [
    "WindowsAzureActiveDirectoryIntegratedApp"
  ]
}

# No way in terraform to make this app role assignment
# so we have to resort to calling the az cli
# for now we just assign one user (the first item in the users
# local var) to the first app_roll. If we ever need to do this
# for multiple users, then we should probably follow the okta
# modules user_group mapping pattern

#resource "azuread_group_member" "this-group-membership" {
#  count            = var.multi_user ? length(local.user_group_app_ids) : 0
#  member_object_id = split("~", local.user_group_app_ids[count.index])[0]
#  group_object_id  = split("~", local.user_group_app_ids[count.index])[1]
#  depends_on       = [azuread_group.this-group, azuread_user.this-user]
#}

resource "null_resource" "app_role_assignment" {
  count      = length(local.user_groups)
  depends_on = [azuread_service_principal.this]
  triggers = {
    app    = azuread_service_principal.this.id
    groups = md5(join(",", local.user_groups))
  }

  provisioner "local-exec" {
    command = "while ! az rest --method GET --uri https://graph.microsoft.com/v1.0/servicePrincipals/${local.sp_id} &> /dev/null; do sleep 1; done; if ! az rest --method GET --uri https://graph.microsoft.com/v1.0/users/${split("~", local.user_groups[count.index])[0]}/appRoleAssignments | grep  ${split("~", local.user_groups[count.index])[1]}; then az rest --method POST --uri https://graph.microsoft.com/v1.0/users/${split("~", local.user_groups[count.index])[0]}/appRoleAssignments --headers '{\"Content-Type\":\"application/json\"}' --body '{\"principalId\": \"${split("~", local.user_groups[count.index])[0]}\", \"resourceId\": \"${local.sp_id}\", \"appRoleId\": \"${split("~", local.user_groups[count.index])[1]}\"}';fi"
  }
}

# If we do not set the password manually there
# is a risk of the generated password causing
# an unhandled escape sequence
resource "azuread_application_password" "this-application-password" {
  application_object_id = azuread_application.this-application.object_id
  #value                 = var.client_secret
}

# query the metadata endpoint to get a json list
# of this IDPS endpoints. used in the outputs
data "http" "metadata" {
  depends_on = [
    azuread_service_principal.this,
    null_resource.app_role_assignment
  ]

  url = local.meta
  request_headers = {
    Accept = "application/json"
  }
}

data "http" "metadata_alt" {
  depends_on = [
    azuread_service_principal.this,
    null_resource.app_role_assignment
  ]

  url = local.meta_alt
  request_headers = {
    Accept = "application/json"
  }
}

# For test users
locals {
  x = flatten([for k, v in var.users :
    [for x in var.users[k].workspaces :
      "${k}~${x}~${v.password}" if x == var.test_workspace
    ]
  ])

  i = random_shuffle.shuf.result[0]

  test_object = {
    user      = length(local.x) > 0 ? split("~", local.x[tonumber(local.i)])[0] : ""
    workspace = length(local.x) > 0 ? split("~", local.x[tonumber(local.i)])[1] : ""
    password  = length(local.x) > 0 ? split("~", local.x[tonumber(local.i)])[2] : ""
  }
}

# used to selct a random idp user for testing with
resource "random_shuffle" "shuf" {
  input        = range(0, length(local.x))
  result_count = 1
}
