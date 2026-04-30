output "regional_resource_groups" {
  value = {
    for k, v in module.rg : k => v.name
  }
}

output "regional_webapps" {
  value = {
    for k, v in module.webapp : k => v.name
  }
}

output "regional_app_gateway_ips" {
  value = {
    for k, v in module.application_gateway : k => v.public_ip_address
  }
}

output "traffic_manager_fqdn" {
  value = module.traffic_manager.fqdn
}

output "jumpbox_public_ips" {
  value = {
    for k, v in module.jumpbox : k => v.public_ip_address
  }
}

output "jumpbox_private_ips" {
  value = {
    for k, v in module.jumpbox : k => v.private_ip_address
  }
}

