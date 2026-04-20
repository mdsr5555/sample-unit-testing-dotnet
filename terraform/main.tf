module "rg" {
  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/resource-group?ref=v1.0.0"

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "vnets" {
  for_each = var.vnets

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/virtual-network?ref=v1.1.0"

  name                = each.key
  location            = module.rg.location
  resource_group_name = module.rg.name
  address_space       = each.value.address_space
  dns_servers         = each.value.dns_servers
  tags                = var.tags
}

resource "azurerm_log_analytics_workspace" "this" {
  name                = var.log_analytics_workspace_name
  location            = module.rg.location
  resource_group_name = module.rg.name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "this" {
  name                = var.application_insights_name
  location            = module.rg.location
  resource_group_name = module.rg.name
  workspace_id        = azurerm_log_analytics_workspace.this.id
  application_type    = "web"
  tags                = var.tags
}

module "plan" {
  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/app-service-plan?ref=v1.0.0"

  app_service_plan_name = var.app_service_plan_name
  location              = module.rg.location
  resource_group_name   = module.rg.name
  os_type               = "Linux"
  sku_name              = "B1"
  tags                  = var.tags
}

module "webapp" {
  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/linux-web-app?ref=v1.0.0"

  web_app_name        = var.web_app_name
  location            = module.rg.location
  resource_group_name = module.rg.name
  app_service_plan_id = module.plan.id
  https_only          = true
  always_on           = false
  dotnet_version      = "8.0"

  app_settings = {
    ASPNETCORE_ENVIRONMENT                     = var.environment
    APPLICATIONINSIGHTS_CONNECTION_STRING      = azurerm_application_insights.this.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
  }

  tags = var.tags
}

# # moved {
# #   from = azurerm_resource_group.this
# #   to   = azurerm_resource_group.rg
# # }

# # moved {
# #   from = azurerm_linux_web_app.this
# #   to   = azurerm_linux_web_app.webapp
# # }

# resource "azurerm_resource_group" "rg" {
#   name     = var.resource_group_name
#   location = var.location
#   tags     = var.tags

#   # lifecycle {
#   #   prevent_destroy = true
#   # }
# }

# resource "azurerm_log_analytics_workspace" "this" {
#   name                = var.log_analytics_workspace_name
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   sku                 = "PerGB2018"
#   retention_in_days   = 30
#   tags                = var.tags
# }

# resource "azurerm_application_insights" "this" {
#   name                = var.application_insights_name
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   workspace_id        = azurerm_log_analytics_workspace.this.id
#   application_type    = "web"
#   tags                = var.tags
# }

# resource "azurerm_service_plan" "this" {
#   name                = var.app_service_plan_name
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   os_type             = "Linux"
#   sku_name            = "B1"
#   tags                = var.tags
# }

# resource "azurerm_linux_web_app" "webapp" {
#   name                = var.web_app_name
#   location            = azurerm_resource_group.rg.location
#   resource_group_name = azurerm_resource_group.rg.name
#   service_plan_id     = azurerm_service_plan.this.id
#   https_only          = true
#   tags                = var.tags

#   site_config {
#     always_on = false

#     application_stack {
#       dotnet_version = "8.0"
#     }

#     # dynamic "ip_restriction" {
#     #   for_each = var.ip_restrictions
#     #   content {
#     #     name       = ip_restriction.value.name
#     #     ip_address = ip_restriction.value.ip_address
#     #     priority   = ip_restriction.value.priority
#     #     action     = ip_restriction.value.action
#     #   }
#     # }
#   }

#   app_settings = {
#     "ASPNETCORE_ENVIRONMENT"                     = var.environment
#     "APPLICATIONINSIGHTS_CONNECTION_STRING"      = azurerm_application_insights.this.connection_string
#     "ApplicationInsightsAgent_EXTENSION_VERSION" = "~3"
#   }
# }