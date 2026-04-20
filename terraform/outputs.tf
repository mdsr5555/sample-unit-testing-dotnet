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

output "storage_account_ids" {
  value = {
    for k, v in module.storage_accounts : k => v.id
  }
}

output "storage_account_names" {
  value = {
    for k, v in module.storage_accounts : k => v.name
  }
}

output "private_endpoint_ids" {
  value = {
    for k, v in module.private_endpoints : k => v.id
  }
}

output "private_endpoint_subnet_ids" {
  value = {
    for k, v in module.private_endpoint_subnets : k => v.id
  }
}

output "private_dns_zone_blob_name" {
  value = module.private_dns_zone_blob.name
}

output "app_service_integration_subnet_id" {
  value = module.app_service_integration_subnet.id
}