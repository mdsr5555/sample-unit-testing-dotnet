variable "project_name" {
  description = "Project name"
  type        = string
}

variable "environment" {
  description = "Environment name"
  type        = string
}

variable "unique_suffix" {
  description = "Short unique suffix"
  type        = string
}

variable "tags" {
  description = "Common tags"
  type        = map(string)
  default     = {}
}

variable "regions" {
  description = "Regional application stacks"
  type = map(object({
    location = string
    short    = string
    priority = number

    vnets = map(object({
      address_space = list(string)
      dns_servers   = optional(list(string), [])
    }))

    app_service_integration_subnet = object({
      vnet_key         = string
      subnet_name      = string
      address_prefixes = list(string)
    })

    private_endpoint_subnet = object({
      vnet_key         = string
      subnet_name      = string
      address_prefixes = list(string)
    })

    application_gateway_subnet = object({
      vnet_key         = string
      subnet_name      = string
      address_prefixes = list(string)
    })
  }))
}

variable "application_gateway_ssl_certificate_name" {
  description = "Application Gateway certificate name"
  type        = string
}

variable "application_gateway_ssl_certificate_data" {
  description = "Base64 encoded PFX certificate content"
  type        = string
  sensitive   = true
}

variable "application_gateway_ssl_certificate_password" {
  description = "PFX certificate password"
  type        = string
  sensitive   = true
}

# variable "enable_secondary_region" {
#   type        = bool
#   description = "Toggle for secondary region deployment"
#   default     = false # Set to false to pause it
# }