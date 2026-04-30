project_name  = "sample-unit-testing-dotnet"
environment   = "dev"
unique_suffix = "mdsr5555"

tags = {
  environment = "dev"
  managed_by  = "terraform"
  owner       = "Mudassar"
  project     = "sample-unit-testing-dotnet"
}

regions = {
  primary = {
    location = "West Europe"
    short    = "weu"
    priority = 1

    vnets = {
      vnet01 = {
        address_space = ["10.10.0.0/24", "10.10.3.0/24"]
      }
      vnet02 = {
        address_space = ["10.10.2.0/24"]
      }
    }

    app_service_integration_subnet = {
      vnet_key         = "vnet01"
      subnet_name      = "snet-appsvc-integration"
      address_prefixes = ["10.10.0.32/27"]
    }

    private_endpoint_subnet = {
      vnet_key         = "vnet01"
      subnet_name      = "snet-private-endpoints"
      address_prefixes = ["10.10.0.64/27"]
    }

    application_gateway_subnet = {
      vnet_key         = "vnet01"
      subnet_name      = "snet-appgw"
      address_prefixes = ["10.10.3.0/24"]
    }

    jumpbox_subnet = {
      vnet_key         = "vnet01"
      subnet_name      = "snet-jumpbox"
      address_prefixes = ["10.10.0.128/27"]
    }
  }

  # secondary = {
  #   location = "Central US"
  #   short    = "cus"
  #   priority = 2

  #   vnets = {
  #     vnet01 = {
  #       address_space = ["10.20.0.0/24"]
  #     }
  #     vnet02 = {
  #       address_space = ["10.20.1.0/24"]
  #     }
  #     vnet03 = {
  #       address_space = ["10.20.2.0/24"]
  #     }
  #     vnet04 = {
  #       address_space = ["10.20.3.0/24"]
  #     }
  #   }

  #   app_service_integration_subnet = {
  #     vnet_key         = "vnet01"
  #     subnet_name      = "snet-appsvc-integration"
  #     address_prefixes = ["10.20.0.32/27"]
  #   }

  #   private_endpoint_subnet = {
  #     vnet_key         = "vnet01"
  #     subnet_name      = "snet-private-endpoints"
  #     address_prefixes = ["10.20.0.64/27"]
  #   }

  #   application_gateway_subnet = {
  #     vnet_key         = "vnet01"
  #     subnet_name      = "snet-appgw"
  #     address_prefixes = ["10.20.0.96/27"]
  #   }
  # }
}

jumpbox_allowed_ssh_cidrs = [
  "82.12.127.151/32"
]

application_gateway_ssl_certificate_name = "appgw-cert"
