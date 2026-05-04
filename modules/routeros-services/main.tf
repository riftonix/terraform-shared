resource "routeros_ip_dns" "this" {
  count = var.dns.enabled ? 1 : 0

  allow_remote_requests = var.dns.allow_remote_requests
  servers               = var.dns.servers
}

resource "routeros_ip_service" "enabled" {
  for_each = var.enabled_services

  numbers  = each.key
  port     = each.value
  disabled = false
}

resource "routeros_ip_service" "disabled" {
  for_each = var.disabled_services

  numbers  = each.key
  port     = each.value
  disabled = true
}
