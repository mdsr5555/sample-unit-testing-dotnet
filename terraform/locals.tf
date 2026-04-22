locals {
  name_suffix = "${var.project_name}-${var.environment}"

  resource_group_name          = "rg-${local.name_suffix}"
  app_service_plan_name        = "asp-${local.name_suffix}"
  web_app_name                 = "${var.project_name}-${var.unique_suffix}-${var.environment}"
  log_analytics_workspace_name = "law-${local.name_suffix}"
  application_insights_name    = "appi-${local.name_suffix}"

  application_gateway_name      = var.application_gateway_name
  application_gateway_public_ip = var.application_gateway_public_ip_name

  storage_account_name = lower(substr(
    replace("st${var.project_name}${var.environment}${var.unique_suffix}", "-", ""),
    0,
    24
  ))
}