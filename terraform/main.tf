data "azurerm_client_config" "current" {}


module "rg" {
  for_each = var.regions

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/resource-group?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name     = local.region_names[each.key].rg_name
  location = each.value.location
  tags     = var.tags
}

module "vnets" {
  for_each = local.flattened_vnets

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/virtual-network?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name                = each.value.name
  location            = each.value.location
  resource_group_name = module.rg[each.value.region_key].name
  address_space       = each.value.address_space
  dns_servers         = each.value.dns_servers
  tags                = var.tags
}

resource "azurerm_log_analytics_workspace" "this" {
  for_each = var.regions

  name                = local.region_names[each.key].law_name
  location            = module.rg[each.key].location
  resource_group_name = module.rg[each.key].name
  sku                 = "PerGB2018"
  retention_in_days   = 30
  tags                = var.tags
}

resource "azurerm_application_insights" "this" {
  for_each = var.regions

  name                = local.region_names[each.key].appi_name
  location            = module.rg[each.key].location
  resource_group_name = module.rg[each.key].name
  workspace_id        = azurerm_log_analytics_workspace.this[each.key].id
  application_type    = "web"
  tags                = var.tags
}

module "key_vault" {
  for_each = var.regions

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/key-vault?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name                          = local.region_names[each.key].kv_name
  location                      = module.rg[each.key].location
  resource_group_name           = module.rg[each.key].name
  tenant_id                     = data.azurerm_client_config.current.tenant_id
  sku_name                      = "standard"
  enable_rbac_authorization     = true
  purge_protection_enabled      = true
  soft_delete_retention_days    = 7
  public_network_access_enabled = false

  network_acls = {
    bypass                     = "AzureServices"
    default_action             = "Deny"
    ip_rules                   = []
    virtual_network_subnet_ids = []
  }

  tags = var.tags
}

module "private_dns_zone_key_vault" {
  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/private-dns-zone?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name                = "privatelink.vaultcore.azure.net"
  resource_group_name = module.rg["primary"].name

  virtual_network_links = {
    for link_key, link in local.private_dns_links :
    link_key => {
      virtual_network_id   = module.vnets[link.virtual_network_key].id
      registration_enabled = false
    }
  }

  tags = var.tags
}

module "key_vault_private_endpoint" {
  for_each = var.regions

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/private-endpoint?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name                            = "pe-${module.key_vault[each.key].name}"
  location                        = module.rg[each.key].location
  resource_group_name             = module.rg[each.key].name
  subnet_id                       = module.private_endpoint_subnet[each.key].id
  private_service_connection_name = "psc-${module.key_vault[each.key].name}"
  private_connection_resource_id  = module.key_vault[each.key].id
  subresource_names               = ["vault"]
  private_dns_zone_group_name     = "default"
  private_dns_zone_ids            = [module.private_dns_zone_key_vault.id]

  tags = var.tags
}



module "plan" {
  for_each = var.regions

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/app-service-plan?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  app_service_plan_name = local.region_names[each.key].asp_name
  location              = module.rg[each.key].location
  resource_group_name   = module.rg[each.key].name
  os_type               = "Linux"
  sku_name              = "B1"
  tags                  = var.tags
}

module "app_service_integration_subnet" {
  for_each = var.regions

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/subnet?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name                 = each.value.app_service_integration_subnet.subnet_name
  resource_group_name  = module.rg[each.key].name
  virtual_network_name = module.vnets["${each.key}-${each.value.app_service_integration_subnet.vnet_key}"].name
  address_prefixes     = each.value.app_service_integration_subnet.address_prefixes

  private_endpoint_network_policies = "Disabled"

  delegation_name         = "appsvc-delegation"
  service_delegation_name = "Microsoft.Web/serverFarms"
  service_delegation_actions = [
    "Microsoft.Network/virtualNetworks/subnets/action"
  ]
}

module "webapp" {
  for_each = var.regions

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/linux-web-app?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  web_app_name              = local.region_names[each.key].web_name
  location                  = module.rg[each.key].location
  resource_group_name       = module.rg[each.key].name
  app_service_plan_id       = module.plan[each.key].id
  https_only                = true
  always_on                 = true
  dotnet_version            = "8.0"
  virtual_network_subnet_id = module.app_service_integration_subnet[each.key].id
  managed_identity_enabled  = true


  app_settings = {
    ASPNETCORE_ENVIRONMENT                     = var.environment
    APPLICATIONINSIGHTS_CONNECTION_STRING      = azurerm_application_insights.this[each.key].connection_string
    ApplicationInsightsAgent_EXTENSION_VERSION = "~3"
    StorageConnectionString                    = module.storage[each.key].primary_connection_string
    REGION                                     = each.value.location
  }

  tags = var.tags
}

module "webapp_key_vault_secrets_user" {
  for_each = var.regions

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/role-assignment?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  scope                = module.key_vault[each.key].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.webapp[each.key].principal_id
}


module "application_gateway_subnet" {
  for_each = var.regions

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/subnet?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name                 = each.value.application_gateway_subnet.subnet_name
  resource_group_name  = module.rg[each.key].name
  virtual_network_name = module.vnets["${each.key}-${each.value.application_gateway_subnet.vnet_key}"].name
  address_prefixes     = each.value.application_gateway_subnet.address_prefixes

  private_endpoint_network_policies = "Disabled"
}

module "application_gateway" {
  for_each = var.regions

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/application-gateway?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name                     = local.region_names[each.key].agw_name
  public_ip_name           = local.region_names[each.key].pip_name
  resource_group_name      = module.rg[each.key].name
  location                 = module.rg[each.key].location
  subnet_id                = module.application_gateway_subnet[each.key].id
  backend_fqdn             = module.webapp[each.key].default_hostname
  health_probe_path        = "/health"
  ssl_certificate_name     = var.application_gateway_ssl_certificate_name
  ssl_certificate_data     = var.application_gateway_ssl_certificate_data
  ssl_certificate_password = var.application_gateway_ssl_certificate_password

  sku_name = "WAF_v2"
  sku_tier = "WAF_v2"
  capacity = 1

  waf_enabled                  = true
  waf_policy_name              = "wafp-${var.project_name}-${var.environment}-${each.value.short}"
  waf_firewall_mode            = "Detection"
  waf_rule_set_type            = "OWASP"
  waf_rule_set_version         = "3.2"
  waf_file_upload_limit_mb     = 100
  waf_max_request_body_size_kb = 128

  tags = var.tags
}

module "application_gateway_identity" {
  for_each = var.regions

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/user-assigned-identity?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name                = local.region_names[each.key].uai_name
  location            = module.rg[each.key].location
  resource_group_name = module.rg[each.key].name
  tags                = var.tags
}

module "application_gateway_key_vault_secrets_user" {
  for_each = var.regions

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/role-assignment?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  scope                = module.key_vault[each.key].id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = module.application_gateway_identity[each.key].principal_id
}



module "application_gateway_diagnostics" {
  for_each = var.regions

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/diagnostic-setting?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name                       = "diag-application-gateway-${each.key}"
  target_resource_id         = module.application_gateway[each.key].id
  log_analytics_workspace_id = azurerm_log_analytics_workspace.this[each.key].id

  log_categories = [
    "ApplicationGatewayAccessLog",
    "ApplicationGatewayFirewallLog"
  ]

  metric_categories = [
    "AllMetrics"
  ]
}

module "storage" {
  for_each = var.regions

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/storage-account?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name                          = local.region_names[each.key].storage_name
  resource_group_name           = module.rg[each.key].name
  location                      = module.rg[each.key].location
  account_tier                  = "Standard"
  account_replication_type      = "LRS"
  account_kind                  = "StorageV2"
  min_tls_version               = "TLS1_2"
  public_network_access_enabled = false

  tags = var.tags
}

module "private_endpoint_subnet" {
  for_each = var.regions

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/subnet?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name                 = each.value.private_endpoint_subnet.subnet_name
  resource_group_name  = module.rg[each.key].name
  virtual_network_name = module.vnets["${each.key}-${each.value.private_endpoint_subnet.vnet_key}"].name
  address_prefixes     = each.value.private_endpoint_subnet.address_prefixes

  private_endpoint_network_policies = "Disabled"
}

module "private_dns_zone_blob" {
  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/private-dns-zone?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name                = "privatelink.blob.core.windows.net"
  resource_group_name = module.rg["primary"].name

  virtual_network_links = {
    for link_key, link in local.private_dns_links :
    link_key => {
      virtual_network_id   = module.vnets[link.virtual_network_key].id
      registration_enabled = link.registration_enabled
    }
  }

  tags = var.tags
}

module "storage_private_endpoint" {
  for_each = var.regions

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/private-endpoint?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name                            = "pe-${local.region_names[each.key].storage_name}-blob"
  location                        = module.rg[each.key].location
  resource_group_name             = module.rg[each.key].name
  subnet_id                       = module.private_endpoint_subnet[each.key].id
  private_service_connection_name = "psc-${local.region_names[each.key].storage_name}-blob"
  private_connection_resource_id  = module.storage[each.key].id
  subresource_names               = ["blob"]
  private_dns_zone_group_name     = "default"
  private_dns_zone_ids            = [module.private_dns_zone_blob.id]
  tags                            = var.tags
}

module "vwan" {
  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/virtual-wan?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name                = "vwan-${var.environment}"
  location            = module.rg["primary"].location
  resource_group_name = module.rg["primary"].name
  tags                = var.tags
}

module "hub" {
  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/virtual-hub?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name                = "vhub-${var.environment}"
  location            = module.rg["primary"].location
  resource_group_name = module.rg["primary"].name
  virtual_wan_id      = module.vwan.id

  address_prefix = "10.100.0.0/24"
  tags           = var.tags
}

module "vnet_connections" {
  for_each = module.vnets

  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/vnet-connection?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name           = "conn-${each.key}"
  virtual_hub_id = module.hub.id
  vnet_id        = each.value.id
}

module "traffic_manager" {
  source = "git::https://github.com/mdsr5555/terraform-templates.git//modules/traffic-manager?ref=5d588f94cdc3346b8fdc3fc958f9596d3cc4f3c9"

  name                = "tm-${var.project_name}-${var.environment}"
  resource_group_name = module.rg["primary"].name

  traffic_routing_method = "Priority"
  relative_name          = "tm-${var.project_name}-${var.environment}"
  ttl                    = 30

  monitor_protocol = "HTTPS"
  monitor_port     = 443
  monitor_path     = "/health"

  endpoints = {
    for region_key, region in var.regions :
    region_key => {
      target            = module.application_gateway[region_key].public_ip_address
      endpoint_location = region.location
      priority          = region.priority
    }
  }

  tags = var.tags
}
