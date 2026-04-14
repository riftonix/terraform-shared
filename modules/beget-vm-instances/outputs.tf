output "instances" {
  description = "Created instances keyed by node name."
  value = {
    for name, instance in beget_compute_instance.this : name => {
      id                   = instance.id
      name                 = instance.name
      ip_address           = try(instance.ip_address, null)
      status               = try(instance.status, null)
      region               = try(instance.region, null)
      slug                 = try(instance.slug, null)
      additional_ip        = try(beget_additional_ip.this[name].ip_address, null)
      generated_public_key = try(beget_ssh_key.this[name].public_key, null)
      generated_private_key = (
        try(tls_private_key.generated[name].private_key_openssh, null) != null
        ? tls_private_key.generated[name].private_key_openssh
        : null
      )
    }
  }
  sensitive = true
}

output "nodes" {
  description = "Normalized nodes keyed by name with `node` and `endpoint` addresses for downstream modules."
  value = {
    for name, instance in beget_compute_instance.this : name => {
      name     = name
      node     = try(instance.ip_address, null)
      endpoint = coalesce(try(beget_additional_ip.this[name].ip_address, null), try(instance.ip_address, null))
    }
  }
}
