output "instances" {
  description = "Created instances keyed by node name."
  value = {
    for name, instance in openstack_compute_instance_v2.this : name => {
      id           = instance.id
      name         = instance.name
      access_ip_v4 = instance.access_ip_v4
      fixed_ip_v4  = try(instance.network[0].fixed_ip_v4, null)
      public_ip_v4 = try(openstack_networking_floatingip_v2.this[name].address, null)
    }
  }
}

output "nodes" {
  description = "Normalized nodes keyed by name with `node` and `endpoint` addresses for downstream modules."
  value = {
    for name, instance in openstack_compute_instance_v2.this : name => {
      name     = name
      node     = coalesce(try(instance.network[0].fixed_ip_v4, null), instance.access_ip_v4)
      endpoint = coalesce(try(instance.network[0].fixed_ip_v4, null), instance.access_ip_v4)
    }
  }
}

output "public_ips" {
  description = "Allocated public floating IPv4 addresses keyed by node name (only for nodes with create_public_ip=true)."
  value = {
    for name, fip in openstack_networking_floatingip_v2.this : name => fip.address
  }
}
