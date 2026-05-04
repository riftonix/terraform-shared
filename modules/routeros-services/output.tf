output "enabled_services" {
  description = "RouterOS services kept enabled"
  value       = keys(routeros_ip_service.enabled)
}

output "disabled_services" {
  description = "RouterOS services disabled by this module"
  value       = keys(routeros_ip_service.disabled)
}
