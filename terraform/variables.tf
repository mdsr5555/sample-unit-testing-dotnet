variable "location" {
  description = "Azure region"
  type        = string
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
}

variable "app_service_plan_name" {
  description = "App Service Plan name"
  type        = string
}

variable "app_service_integration_subnet" {
  description = "Subnet configuration for App Service VNet Integration"
  type = object({
    vnet_key         = string
    subnet_name      = string
    address_prefixes = list(string)
  })
}

variable "web_app_name" {
  description = "Web App name"
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name"
  type        = string
}

variable "application_insights_name" {
  description = "Application Insights name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default     = {}
}

variable "vnets" {
  description = "Map of virtual networks to create"
  type = map(object({
    address_space = list(string)
    dns_servers   = optional(list(string), [])
  }))
  default = {}
}

variable "storage_accounts" {
  description = "Storage accounts to create"
  type = map(object({
    name = string
  }))
}

variable "private_endpoint_subnets" {
  description = "Subnets for private endpoints"
  type = map(object({
    vnet_key         = string
    subnet_name      = string
    address_prefixes = list(string)
  }))
}

variable "private_endpoint_subnet" {
  description = "Subnet configuration for storage private endpoint"
  type = object({
    vnet_key         = string
    subnet_name      = string
    address_prefixes = list(string)
  })
}

// variables for aplication gateway
variable "application_gateway_subnet" {
  description = "Subnet configuration for Application Gateway"
  type = object({
    vnet_key         = string
    subnet_name      = string
    address_prefixes = list(string)
  })
}

variable "application_gateway_name" {
  description = "Application Gateway name"
  type        = string
}

variable "application_gateway_public_ip_name" {
  description = "Public IP name for Application Gateway"
  type        = string
}

variable "application_gateway_ssl_certificate_name" {
  description = "SSL certificate name for Application Gateway"
  type        = string
}

variable "application_gateway_ssl_certificate_data" {
  description = "Base64-encoded PFX certificate data"
  type        = string
  sensitive   = true
}

variable "application_gateway_ssl_certificate_password" {
  description = "Password for the PFX certificate"
  type        = string
  sensitive   = true
}