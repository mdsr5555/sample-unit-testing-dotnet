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

// variables needed for adding AFD

variable "frontdoor_profile_name" {
  description = "Azure Front Door profile name"
  type        = string
}

variable "frontdoor_endpoint_name" {
  description = "Azure Front Door endpoint name"
  type        = string
}

variable "frontdoor_origin_group_name" {
  description = "Azure Front Door origin group name"
  type        = string
}

variable "frontdoor_origin_name" {
  description = "Azure Front Door origin name"
  type        = string
}

variable "frontdoor_route_name" {
  description = "Azure Front Door route name"
  type        = string
}