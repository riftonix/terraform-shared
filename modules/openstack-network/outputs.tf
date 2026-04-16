output "network" {
  description = "Created OpenStack network details."
  value = {
    id                    = openstack_networking_network_v2.this.id
    name                  = openstack_networking_network_v2.this.name
    description           = openstack_networking_network_v2.this.description
    admin_state_up        = openstack_networking_network_v2.this.admin_state_up
    port_security_enabled = openstack_networking_network_v2.this.port_security_enabled
    mtu                   = openstack_networking_network_v2.this.mtu
    dns_domain            = openstack_networking_network_v2.this.dns_domain
    tags                  = openstack_networking_network_v2.this.tags
  }
}

output "subnets" {
  description = "Created subnets keyed by subnet name."
  value = {
    for name, subnet in openstack_networking_subnet_v2.this : name => {
      id                   = subnet.id
      name                 = subnet.name
      description          = subnet.description
      cidr                 = subnet.cidr
      ip_version           = subnet.ip_version
      gateway_ip           = subnet.gateway_ip
      enable_dhcp          = subnet.enable_dhcp
      dns_nameservers      = subnet.dns_nameservers
      dns_publish_fixed_ip = subnet.dns_publish_fixed_ip
      service_types        = subnet.service_types
      segment_id           = subnet.segment_id
      subnetpool_id        = subnet.subnetpool_id
      tags                 = subnet.tags
      allocation_pool      = subnet.allocation_pool
    }
  }
}

output "input_subnets" {
  description = "Raw subnets structure passed to the module input."
  value       = var.subnets
}
