terraform {
  backend "azurerm" {
    resource_group_name  = "rg-mudassardevops"
    storage_account_name = "samockstorage"
    container_name       = "mockcontainer"
    key                  = "sample-unit-testing-dotnet-dev.tfstate"
  }
}