location                     = "West Europe"
resource_group_name          = "rg-sample-unit-testing-dotnet-dev"
app_service_plan_name        = "asp-sample-unit-testing-dotnet-dev"
web_app_name                 = "sample-unit-testing-dotnet-mdsr5555-dev"
log_analytics_workspace_name = "law-sample-unit-testing-dotnet-dev"
application_insights_name    = "appi-sample-unit-testing-dotnet-dev"
environment                  = "dev"
# ip_restrictions = [
#   {
#     name       = "home"
#     ip_address = "1.2.3.4/32"
#     priority   = 100
#     action     = "Allow"
#   },
#   {
#     name       = "office"
#     ip_address = "5.6.7.8/32"
#     priority   = 110
#     action     = "Allow"
#   }
# ]

tags = {
  environment = "dev"
  managed_by  = "terraform"
  owner       = "Mudassar"
  project     = "sample-unit-testing-dotnet"
}