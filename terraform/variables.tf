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