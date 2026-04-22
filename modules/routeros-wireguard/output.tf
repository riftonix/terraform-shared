output "interface_name" {
  description = "Local WireGuard interface name"
  value       = routeros_interface_wireguard.this.name
}

output "interface_address" {
  description = "Local WireGuard interface address"
  value       = routeros_ip_address.this.address
}

output "listen_port" {
  description = "WireGuard listen port"
  value       = routeros_interface_wireguard.this.listen_port
}

output "public_key" {
  description = "Local WireGuard public key"
  value       = routeros_interface_wireguard.this.public_key
}

output "private_key" {
  description = "Local WireGuard private key"
  value       = routeros_interface_wireguard.this.private_key
  sensitive   = true
}

output "public_endpoint_address" {
  description = "Public address that remote peers should use to reach this WireGuard instance"
  value       = try(var.interface.public_endpoint_address, null)
}

output "road_warrior_configs" {
  description = "Rendered WireGuard client configs for road-warrior peers that have a private key in Terraform"
  value = {
    for peer_name, cfg in data.wireguard_config_document.road_warrior :
    peer_name => cfg.conf
  }
  sensitive = true
}
