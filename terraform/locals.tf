locals {
  region_names = {
    for region_key, region in var.regions :
    region_key => {
      rg_name      = "rg-${var.project_name}-${var.environment}-${region.short}"
      law_name     = "law-${var.project_name}-${var.environment}-${region.short}"
      appi_name    = "appi-${var.project_name}-${var.environment}-${region.short}"
      asp_name     = "asp-${var.project_name}-${var.environment}-${region.short}"
      web_name     = "${var.project_name}-${var.unique_suffix}-${var.environment}-${region.short}"
      agw_name     = "agw-${var.project_name}-${var.environment}-${region.short}"
      pip_name     = "pip-agw-${var.project_name}-${var.environment}-${region.short}"
      storage_name = substr(lower("st${region.short}${var.environment}${var.unique_suffix}"), 0, 24)
      kv_name      = substr(lower("kv-${var.project_name}-${var.environment}-${region.short}"), 0, 24)
      uai_name     = "uai-agw-${var.project_name}-${var.environment}-${region.short}"
      jumpbox_name = "vm-jumpbox-${var.environment}-${region.short}"
      jumpbox_pip  = "pip-jumpbox-${var.environment}-${region.short}"
      jumpbox_nic  = "nic-jumpbox-${var.environment}-${region.short}"
      jumpbox_nsg  = "nsg-jumpbox-${var.environment}-${region.short}"
    }
  }

  flattened_vnets = merge([
    for region_key, region in var.regions : {
      for vnet_key, vnet in region.vnets :
      "${region_key}-${vnet_key}" => {
        region_key    = region_key
        location      = region.location
        name          = "${vnet_key}-${var.environment}-${region.short}"
        address_space = vnet.address_space
        dns_servers   = try(vnet.dns_servers, [])
      }
    }
  ]...)

  private_dns_links = {
    for region_key, region in var.regions :
    "${region_key}-link" => {
      virtual_network_key  = "${region_key}-${region.private_endpoint_subnet.vnet_key}"
      registration_enabled = false
    }
  }
}
