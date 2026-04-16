output "router" {
  description = "Created OpenStack router details."
  value = {
    id                  = openstack_networking_router_v2.this.id
    name                = openstack_networking_router_v2.this.name
    external_network_id = openstack_networking_router_v2.this.external_network_id
    enable_snat         = openstack_networking_router_v2.this.enable_snat
    tags                = openstack_networking_router_v2.this.tags
  }
}

output "interfaces" {
  description = "Created router interfaces keyed by subnet_id."
  value = {
    for iface in openstack_networking_router_interface_v2.this : iface.subnet_id => {
      router_id = iface.router_id
      subnet_id = iface.subnet_id
      port_id   = iface.port_id
    }
  }
}

output "attached_subnet_ids" {
  description = "Effective list of subnet IDs attached to the router."
  value       = sort([for iface in openstack_networking_router_interface_v2.this : iface.subnet_id])
}
