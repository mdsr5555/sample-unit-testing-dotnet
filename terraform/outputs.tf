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