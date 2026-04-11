output "instances" {
  description = "Created instances keyed by node name."
  value = {
    for name, instance in vsphere_virtual_machine.this : name => {
      id           = instance.id
      name         = instance.name
      access_ip_v4 = try(instance.default_ip_address, null)
      fixed_ip_v4  = try(instance.default_ip_address, null)
    }
  }
}

output "nodes" {
  description = "Normalized nodes keyed by name with `node` and `endpoint` addresses for downstream modules."
  value = {
    for name, instance in vsphere_virtual_machine.this : name => {
      name     = name
      node     = try(instance.default_ip_address, null)
      endpoint = try(instance.default_ip_address, null)
    }
  }
}
