output "instances" {
  description = "Created instances keyed by node name."
  value = {
    for name, instance in proxmox_vm_qemu.this : name => {
      id                   = instance.id
      name                 = instance.name
      vmid                 = instance.vmid
      target_node          = instance.target_node
      current_node         = try(instance.current_node, null)
      default_ipv4_address = try(instance.default_ipv4_address, null)
      default_ipv6_address = try(instance.default_ipv6_address, null)
      access_ip_v4         = try(instance.default_ipv4_address, null)
      fixed_ip_v4          = try(instance.default_ipv4_address, null)
      ssh_host             = try(instance.ssh_host, null)
      ssh_port             = try(instance.ssh_port, null)
    }
  }
}

output "nodes" {
  description = "Normalized nodes keyed by name with `node` and `endpoint` addresses for downstream modules."
  value = {
    for name, instance in proxmox_vm_qemu.this : name => {
      name     = name
      node     = try(instance.default_ipv4_address, null)
      endpoint = try(instance.default_ipv4_address, null)
    }
  }
}
