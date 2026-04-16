location                     = "West Europe"
resource_group_name          = "rg-sample-unit-testing-dotnet-dev"
app_service_plan_name        = "asp-sample-unit-testing-dotnet-dev"
web_app_name                 = "sample-unit-testing-dotnet-mdsr5555-dev"
log_analytics_workspace_name = "law-sample-unit-testing-dotnet-dev"
application_insights_name    = "appi-sample-unit-testing-dotnet-dev"

tags = {
  project     = "sample-unit-testing-dotnet"
  environment = "dev"
  owner       = "Mudassar"
  managed_by  = "terraform"
}