module "rg" {
  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/resource-group?ref=v1.0.0"

  name     = var.resource_group_name
  location = var.location
  tags     = var.tags
}

module "vnets" {
  for_each = var.vnets

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/virtual-network?ref=v1.1.1"

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

  # dynamic "ip_restriction" {
  #   for_each = var.ip_restrictions
  #   content {
  #     name       = ip_restriction.value.name
  #     ip_address = ip_restriction.value.ip_address
  #     priority   = ip_restriction.value.priority
  #     action     = ip_restriction.value.action
  #   }
  # }

  app_settings = {
    ASPNETCORE_ENVIRONMENT                     = var.environment
    APPLICATIONINSIGHTS_CONNECTION_STRING      = azurerm_application_insights.this.connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
  }

  tags = var.tags
}

module "vwan" {
  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/virtual-wan?ref=v1.2.0"

  name                = "vwan-main"
  location            = module.rg.location
  resource_group_name = module.rg.name
  tags                = var.tags
}

module "hub" {
  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/virtual-hub?ref=v1.2.0"

  name                = "vhub-main"
  location            = module.rg.location
  resource_group_name = module.rg.name
  virtual_wan_id      = module.vwan.id

  address_prefix = "10.100.0.0/24" # hub network
  tags           = var.tags
}

module "vnet_connections" {
  for_each = module.vnets

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/vnet-connection?ref=v1.2.0"

  name           = "conn-${each.key}"
  virtual_hub_id = module.hub.id
  vnet_id        = each.value.id
}

module "private_dns_zone_blob" {
  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/private-dns-zone?ref=v1.3.0"

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = module.rg.name

  virtual_network_links = {
    vnet01-link = {
      virtual_network_id   = module.vnets["vnet01"].id
      registration_enabled = false
    }
    vnet02-link = {
      virtual_network_id   = module.vnets["vnet02"].id
      registration_enabled = false
    }
  }

  tags = var.tags
}

module "private_endpoint_subnets" {
  for_each = var.private_endpoint_subnets

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/subnet?ref=v1.3.0"

  name                 = each.value.subnet_name
  resource_group_name  = module.rg.name
  virtual_network_name = module.vnets[each.value.vnet_key].name
  address_prefixes     = each.value.address_prefixes

  private_endpoint_network_policies = "Disabled"
}

module "storage_accounts" {
  for_each = var.storage_accounts

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/storage-account?ref=v1.3.0"

  name                          = each.value.name
  resource_group_name           = module.rg.name
  location                      = module.rg.location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = false

  tags = var.tags
}

module "private_endpoints" {
  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/private-endpoint?ref=v1.3.0"
  for_each = {
    storage1 = {
      name                      = "pe-stapp001-blob"
      subnet_id                 = module.private_endpoint_subnets["pe-subnet-vnet01"].id
      target_resource_id        = module.storage_accounts["stapp001"].id
      private_service_conn_name = "psc-stapp001-blob"
    }
    storage2 = {
      name                      = "pe-stapp002-blob"
      subnet_id                 = module.private_endpoint_subnets["pe-subnet-vnet02"].id
      target_resource_id        = module.storage_accounts["stapp002"].id
      private_service_conn_name = "psc-stapp002-blob"
    }
  }

  name                            = each.value.name
  location                        = module.rg.location
  resource_group_name             = module.rg.name
  subnet_id                       = each.value.subnet_id
  private_service_connection_name = each.value.private_service_conn_name
  private_connection_resource_id  = each.value.target_resource_id
  subresource_names               = ["blob"]
  private_dns_zone_group_name     = "default"
  private_dns_zone_ids            = [module.private_dns_zone_blob.id]
  tags                            = var.tags
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