variable "location" {
  description = "Azure region"
  type        = string
  default     = "UK South"
}

variable "resource_group_name" {
  description = "Resource group name"
  type        = string
  default     = "rg-sample-unit-testing-dotnet-dev"
}

variable "app_service_plan_name" {
  description = "App Service Plan name"
  type        = string
  default     = "asp-sample-unit-testing-dotnet-dev"
}

variable "web_app_name" {
  description = "Web App name. Must be globally unique."
  type        = string
}

variable "log_analytics_workspace_name" {
  description = "Log Analytics Workspace name"
  type        = string
  default     = "law-sample-unit-testing-dotnet-dev"
}

variable "application_insights_name" {
  description = "Application Insights name"
  type        = string
  default     = "appi-sample-unit-testing-dotnet-dev"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "dev"
}

variable "tags" {
  description = "Common resource tags"
  type        = map(string)
  default = {
    project     = "sample-unit-testing-dotnet"
    environment = "dev"
    managed_by  = "terraform"
  }
}

variable "ip_restrictions" {
  description = "IP restrcitions of the web app"
  type = list(
    object(
      {
        name       = string
        ip_address = string
        priority   = number
        action     = string
      }
    )
  )
  default = []
}