output "server_network" {
  description = "Return all information about server network"
  value       = twc_server.this.networks
}

output "server_public_ip" {
  description = "Return server public IP"
  value       = twc_server.this.main_ipv4
}

output "server_name" {
  description = "Return server name"
  value       = twc_server.this.name
}

output "server_id" {
  description = "Return server id"
  value       = twc_server.this.id
}

output "server_cloud_init" {
  description = "Return cloud init script"
  value       = twc_server.this.cloud_init
}
