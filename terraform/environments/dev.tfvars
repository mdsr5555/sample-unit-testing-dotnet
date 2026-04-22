project_name  = "sample-unit-testing-dotnet"
environment   = "dev"
location      = "West Europe"
unique_suffix = "mdsr5555"

tags = {
  environment = "dev"
  managed_by  = "terraform"
  owner       = "Mudassar"
  project     = "sample-unit-testing-dotnet"
}

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
}

app_service_integration_subnet = {
  vnet_key         = "vnet01"
  subnet_name      = "snet-appsvc-integration"
  address_prefixes = ["10.10.0.32/27"]
}

private_endpoint_subnets = {
  pe-subnet-vnet01 = {
    vnet_key         = "vnet01"
    subnet_name      = "snet-private-endpoints-01"
    address_prefixes = ["10.10.0.64/27"]
  }
}

application_gateway_subnet = {
  vnet_key         = "vnet01"
  subnet_name      = "snet-appgw-01"
  address_prefixes = ["10.10.0.96/27"]
}

application_gateway_name                 = "agw-sample-unit-testing-dotnet-dev"
application_gateway_public_ip_name       = "pip-agw-sample-unit-testing-dotnet-dev"
application_gateway_ssl_certificate_name = "appgw-cert"