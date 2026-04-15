output "resource_group_name" {
  value = azurerm_resource_group.this.name
}

output "web_app_name" {
  value = azurerm_linux_web_app.this.name
}

output "web_app_url" {
  value = "https://${azurerm_linux_web_app.this.default_hostname}"
}

output "application_insights_name" {
  value = azurerm_application_insights.this.name
}