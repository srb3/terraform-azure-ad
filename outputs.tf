output "client_id" {
  value = azuread_application.this-application.application_id
}

output "client_secret" {
  value = azuread_application_password.this-application-password.value
}

output "base-url" {
  value = local.base
}

output "metadata-url" {
  value = local.meta
}

output "token_endpoint" {
  value = jsondecode(data.http.metadata.body).token_endpoint
}

output "jwks_uri" {
  value = jsondecode(data.http.metadata.body).jwks_uri
}

output "issuer" {
  value = jsondecode(data.http.metadata.body).issuer
}

output "userinfo_endpoint" {
  value = jsondecode(data.http.metadata.body).userinfo_endpoint
}

output "authorization_endpoint" {
  value = jsondecode(data.http.metadata.body).authorization_endpoint
}

output "device_authorization_endpoint" {
  value = jsondecode(data.http.metadata.body).device_authorization_endpoint
}

output "end_session_endpoint" {
  value = jsondecode(data.http.metadata.body).end_session_endpoint
}

output "kerberos_endpoint" {
  value = jsondecode(data.http.metadata.body).kerberos_endpoint
}

output "test_user" {
  value = local.test_object.user
}

output "test_password" {
  value = local.test_object.password
}

output "test_workspace" {
  value = local.test_object.workspace
}

output "app_role_debug" {
  value = local.app_role_debug
}

output "metadata-url-alt" {
  value = local.meta_alt
}

output "token_endpoint_alt" {
  value = jsondecode(data.http.metadata_alt.body).token_endpoint
}

output "jwks_uri_alt" {
  value = jsondecode(data.http.metadata_alt.body).jwks_uri
}

output "issuer_alt" {
  value = jsondecode(data.http.metadata_alt.body).issuer
}

output "userinfo_endpoint_alt" {
  value = jsondecode(data.http.metadata_alt.body).userinfo_endpoint
}

output "authorization_endpoint_alt" {
  value = jsondecode(data.http.metadata_alt.body).authorization_endpoint
}

output "device_authorization_endpoint_alt" {
  value = jsondecode(data.http.metadata_alt.body).device_authorization_endpoint
}

output "end_session_endpoint_alt" {
  value = jsondecode(data.http.metadata_alt.body).end_session_endpoint
}

output "kerberos_endpoint_alt" {
  value = jsondecode(data.http.metadata_alt.body).kerberos_endpoint
}
