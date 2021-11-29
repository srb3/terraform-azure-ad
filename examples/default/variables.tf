variable "azure_ad_tenant_id" {}

variable "client_secret" {
  type = string
}

variable "redirect_uris" {
  type = list(string)
}

variable "manager_users" {
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

########### Multi user Azure settings ############

# If you have an Azure account with the correct permisions to create users
# and groups, then set the following setting to true.

variable "multi_user" {
  description = "If your Azure account has permisions to create users set this to true"
  type        = bool
  default     = false
}

variable "kong_token" {
  default = "4LNwU9cfznbB"
}

variable "kong_admin_api" {
  default = "https://admin.kongcx.ninja:8444"
}

variable "service_endpoint" {
  default = "https://proxy.kongcx.ninja/httpbin-azure"
}

variable "workspace" {
  default = "internal-apis"
}
