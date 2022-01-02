variable "display_name" {
  description = "The display name for the application"
  type        = string
}

variable "identifier_uris" {
  description = "A list of identifier uris"
  type        = list(string)
  default     = []
}

variable "sign_in_audience" {
  description = "The sign in audiance to use for this app"
  type        = string
  default     = "AzureADMyOrg"
}

variable "group_membership_claims" {
  description = "The group membership claims to use"
  type        = string
  default     = "None"
}

variable "requested_access_token_version" {
  description = "The access token version to use"
  type        = number
  default     = 1
}

variable "oauth2_permission_scope" {
  description = "A list of objects that describe permision scopes to create"
  type = list(object({
    admin_consent_description  = string
    admin_consent_display_name = string
    enabled                    = bool
    id                         = string
    type                       = string
    user_consent_description   = string
    user_consent_display_name  = string
    value                      = string
  }))
  default = []
}

variable "redirect_uris" {
  description = "A list of redirect uris to associate with the application"
  type        = list(string)
}

variable "client_secret" {
  description = "The client secret to use for this application"
  type        = string
  default     = "MeF-U0QumF_bN1M_32QHcpFcN4zRu_g163"
}

variable "users" {
  # Note: we do not have permissions to create users in AD
  # so we just use the one user, the AD user of the person
  # running the terraform
  description = "A map of users to create in azure ad"
  type = map(object({
    email      = string
    first_name = string
    last_name  = string
    password   = string
    workspaces = list(string)
    groups     = list(string)
  }))
  default = {}
}

variable "set_scopes" {
  type    = bool
  default = false
}

variable "scopes" {
  type    = list(map(any))
  default = []
}

variable "test_workspace" {
  description = "The name of the workspace we will be targeting for tests"
  type        = string
  default     = "default"
}

########### Multi user Azure settings ############

# If you have an Azure account with the correct permisions to create users
# and groups, then set the following setting to true.

variable "multi_user" {
  description = "If your Azure account has permisions to create users set this to true"
  type        = bool
  default     = false
}
