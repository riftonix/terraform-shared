output "instances" {
  description = "Created instances keyed by node name."
  value = {
    for name, instance in openstack_compute_instance_v2.this : name => {
      id           = instance.id
      name         = instance.name
      access_ip_v4 = instance.access_ip_v4
      fixed_ip_v4  = try(instance.network[0].fixed_ip_v4, null)
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
