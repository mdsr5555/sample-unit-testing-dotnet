output "resource_group_name" {
  value = module.rg.name
}

output "web_app_name" {
  value = module.webapp.name
}

output "web_app_url" {
  value = "https://${module.webapp.default_hostname}"
}

output "application_insights_name" {
  value = azurerm_application_insights.this.name
}

output "app_service_plan_name" {
  value = module.plan.name
}

output "application_gateway_id" {
  value = module.application_gateway.id
}

output "application_gateway_public_ip" {
  value = module.application_gateway.public_ip_address
}

output "private_endpoint_subnet_ids" {
  value = {
    for k, v in module.private_endpoint_subnets : k => v.id
  }
}

output "vnet_ids" {
  value = {
    for k, v in module.vnets : k => v.id
  }
}