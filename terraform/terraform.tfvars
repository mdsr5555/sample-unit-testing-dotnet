location              = "West Europe"
resource_group_name   = "rg-sample-unit-testing-dotnet-dev"
app_service_plan_name = "asp-sample-unit-testing-dotnet-dev"
web_app_name          = "sample-unit-testing-dotnet-mdsr5555-dev"

app_service_integration_subnet = {
  vnet_key         = "vnet01"
  subnet_name      = "snet-appsvc-integration-01"
  address_prefixes = ["10.10.0.32/27"]
}

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

vnets = {
  vnet01 = {
    address_space = ["10.10.0.0/24"]
  }
  vnet02 = {
    address_space = ["10.10.1.0/24"]
  }
  vnet03 = {
    address_space = ["10.10.2.0/24"]
  }
  vnet04 = {
    address_space = ["10.10.3.0/24"]
  }
  vnet05 = {
    address_space = ["10.10.4.0/24"]
  }
  vnet06 = {
    address_space = ["10.10.5.0/24"]
  }
  vnet07 = {
    address_space = ["10.10.6.0/24"]
  }
  vnet08 = {
    address_space = ["10.10.7.0/24"]
  }
  vnet09 = {
    address_space = ["10.10.8.0/24"]
  }
  vnet10 = {
    address_space = ["10.10.9.0/24"]
  }
}

private_endpoint_subnets = {
  pe-subnet-vnet01 = {
    vnet_key         = "vnet01"
    subnet_name      = "snet-private-endpoints-01"
    address_prefixes = ["10.10.0.0/27"]
  }

  pe-subnet-vnet02 = {
    vnet_key         = "vnet02"
    subnet_name      = "snet-private-endpoints-02"
    address_prefixes = ["10.10.1.0/27"]
  }
}

storage_accounts = {
  stapp001 = {
    name = "stapp001mdsr001"
  }

  stapp002 = {
    name = "stapp002mdsr001"
  }
}

tags = {
  environment = "dev"
  managed_by  = "terraform"
  owner       = "Mudassar"
  project     = "sample-unit-testing-dotnet"
}

storage_connection_string = "your-storage-connection-string-here"