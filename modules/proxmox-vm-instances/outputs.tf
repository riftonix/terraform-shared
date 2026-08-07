output "instances" {
  description = "Created instances keyed by node name."
  value = {
    for name, instance in proxmox_vm_qemu.this : name => {
      id                   = instance.id
      name                 = instance.name
      vmid                 = instance.vmid
      target_node          = instance.target_node
      current_node         = try(instance.current_node, null)
      default_ipv4_address = try(coalesce(instance.default_ipv4_address, local.discovered_ipv4_by_node[name]), null)
      default_ipv6_address = try(instance.default_ipv6_address, null)
      access_ip_v4         = try(coalesce(instance.default_ipv4_address, local.discovered_ipv4_by_node[name]), null)
      fixed_ip_v4          = try(var.nodes[name].fixed_ip_v4, null)
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
      node     = try(coalesce(instance.default_ipv4_address, local.discovered_ipv4_by_node[name]), null)
      endpoint = try(coalesce(instance.default_ipv4_address, local.discovered_ipv4_by_node[name]), null)
    }
  }
}
