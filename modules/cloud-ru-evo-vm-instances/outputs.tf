output "instances" {
  description = "Created instances keyed by node name."
  value = {
    for name, instance in cloudru_evolution_compute_vm.this : name => {
      id           = instance.id
      name         = instance.name
      interface_id = cloudru_evolution_compute_interface.this[name].id
      access_ip_v4 = try(cloudru_evolution_compute_interface.this[name].external_ip.ip_address, null)
      fixed_ip_v4  = try(cloudru_evolution_compute_interface.this[name].ip_address, null)
    }
  }
}

output "nodes" {
  description = "Normalized nodes keyed by name with `node` and `endpoint` addresses for downstream modules."
  value = {
    for name, instance in cloudru_evolution_compute_vm.this : name => {
      name     = name
      node     = try(cloudru_evolution_compute_interface.this[name].ip_address, null)
      endpoint = try(cloudru_evolution_compute_interface.this[name].ip_address, null)
    }
  }
}
