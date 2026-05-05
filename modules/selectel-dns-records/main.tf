locals {
  zone_name = endswith(var.zone_name, ".") ? var.zone_name : "${var.zone_name}."

  a_rrsets = {
    for name, record in var.a_records : "A ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}" => {
      name    = name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}"
      type    = "A"
      ttl     = coalesce(try(record.ttl, null), var.default_ttl)
      comment = try(record.comment, null)
      records = [
        for address in record.addresses : {
          content  = address
          disabled = try(record.disabled, false)
        }
      ]
    }
  }

  aaaa_rrsets = {
    for name, record in var.aaaa_records : "AAAA ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}" => {
      name    = name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}"
      type    = "AAAA"
      ttl     = coalesce(try(record.ttl, null), var.default_ttl)
      comment = try(record.comment, null)
      records = [
        for address in record.addresses : {
          content  = address
          disabled = try(record.disabled, false)
        }
      ]
    }
  }

  cname_rrsets = {
    for name, record in var.cname_records : "CNAME ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}" => {
      name    = name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}"
      type    = "CNAME"
      ttl     = coalesce(try(record.ttl, null), var.default_ttl)
      comment = try(record.comment, null)
      records = [{
        content  = endswith(record.target, ".") ? record.target : "${record.target}."
        disabled = try(record.disabled, false)
      }]
    }
  }

  alias_rrsets = {
    for name, record in var.alias_records : "ALIAS ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}" => {
      name    = name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}"
      type    = "ALIAS"
      ttl     = coalesce(try(record.ttl, null), var.default_ttl)
      comment = try(record.comment, null)
      records = [{
        content  = endswith(record.target, ".") ? record.target : "${record.target}."
        disabled = try(record.disabled, false)
      }]
    }
  }

  txt_rrsets = {
    for name, record in var.txt_records : "TXT ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}" => {
      name    = name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}"
      type    = "TXT"
      ttl     = coalesce(try(record.ttl, null), var.default_ttl)
      comment = try(record.comment, null)
      records = [
        for value in record.values : {
          content  = startswith(value, "\"") && endswith(value, "\"") ? value : "\"${value}\""
          disabled = try(record.disabled, false)
        }
      ]
    }
  }

  mx_rrsets = {
    for name, record in var.mx_records : "MX ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}" => {
      name    = name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}"
      type    = "MX"
      ttl     = coalesce(try(record.ttl, null), var.default_ttl)
      comment = try(record.comment, null)
      records = [
        for item in record.records : {
          content  = "${item.priority} ${endswith(item.host, ".") ? item.host : "${item.host}."}"
          disabled = try(record.disabled, false)
        }
      ]
    }
  }

  ns_rrsets = {
    for name, record in var.ns_records : "NS ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}" => {
      name    = name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}"
      type    = "NS"
      ttl     = coalesce(try(record.ttl, null), var.default_ttl)
      comment = try(record.comment, null)
      records = [
        for nameserver in record.nameservers : {
          content  = endswith(nameserver, ".") ? nameserver : "${nameserver}."
          disabled = try(record.disabled, false)
        }
      ]
    }
  }

  srv_rrsets = {
    for name, record in var.srv_records : "SRV ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}" => {
      name    = name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}"
      type    = "SRV"
      ttl     = coalesce(try(record.ttl, null), var.default_ttl)
      comment = try(record.comment, null)
      records = [
        for item in record.records : {
          content  = "${item.priority} ${item.weight} ${item.port} ${endswith(item.target, ".") ? item.target : "${item.target}."}"
          disabled = try(record.disabled, false)
        }
      ]
    }
  }

  sshfp_rrsets = {
    for name, record in var.sshfp_records : "SSHFP ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}" => {
      name    = name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}"
      type    = "SSHFP"
      ttl     = coalesce(try(record.ttl, null), var.default_ttl)
      comment = try(record.comment, null)
      records = [
        for item in record.records : {
          content  = "${item.algorithm} ${item.fingerprint_type} ${item.fingerprint}"
          disabled = try(record.disabled, false)
        }
      ]
    }
  }

  caa_rrsets = {
    for name, record in var.caa_records : "CAA ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}" => {
      name    = name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}"
      type    = "CAA"
      ttl     = coalesce(try(record.ttl, null), var.default_ttl)
      comment = try(record.comment, null)
      records = [
        for item in record.records : {
          content  = "${item.flag} ${item.tag} ${startswith(item.value, "\"") && endswith(item.value, "\"") ? item.value : "\"${item.value}\""}"
          disabled = try(record.disabled, false)
        }
      ]
    }
  }

  raw_rrsets = {
    for key, rrset in var.rrsets : "${upper(rrset.type)} ${lower(rrset.name == "@" ? local.zone_name : endswith(rrset.name, ".") ? rrset.name : "${rrset.name}.${local.zone_name}")}" => {
      name    = rrset.name == "@" ? local.zone_name : endswith(rrset.name, ".") ? rrset.name : "${rrset.name}.${local.zone_name}"
      type    = upper(rrset.type)
      ttl     = rrset.ttl
      comment = try(rrset.comment, null)
      records = rrset.records
    }
  }

  rrsets = merge(
    local.a_rrsets,
    local.aaaa_rrsets,
    local.cname_rrsets,
    local.alias_rrsets,
    local.txt_rrsets,
    local.mx_rrsets,
    local.ns_rrsets,
    local.srv_rrsets,
    local.sshfp_rrsets,
    local.caa_rrsets,
    local.raw_rrsets,
  )

  rrset_identity_keys = concat(
    [for name in keys(var.a_records) : "A ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}"],
    [for name in keys(var.aaaa_records) : "AAAA ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}"],
    [for name in keys(var.cname_records) : "CNAME ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}"],
    [for name in keys(var.alias_records) : "ALIAS ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}"],
    [for name in keys(var.txt_records) : "TXT ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}"],
    [for name in keys(var.mx_records) : "MX ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}"],
    [for name in keys(var.ns_records) : "NS ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}"],
    [for name in keys(var.srv_records) : "SRV ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}"],
    [for name in keys(var.sshfp_records) : "SSHFP ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}"],
    [for name in keys(var.caa_records) : "CAA ${lower(name == "@" ? local.zone_name : endswith(name, ".") ? name : "${name}.${local.zone_name}")}"],
    [for rrset in values(var.rrsets) : "${upper(rrset.type)} ${lower(rrset.name == "@" ? local.zone_name : endswith(rrset.name, ".") ? rrset.name : "${rrset.name}.${local.zone_name}")}"],
  )
}

resource "selectel_domains_rrset_v2" "this" {
  for_each = local.rrsets

  zone_id    = var.zone_id
  project_id = var.project_id
  name       = each.value.name
  type       = each.value.type
  ttl        = each.value.ttl
  comment    = try(each.value.comment, null)

  dynamic "records" {
    for_each = each.value.records
    content {
      content  = records.value.content
      disabled = try(records.value.disabled, false)
    }
  }

  lifecycle {
    precondition {
      condition     = length(local.rrset_identity_keys) == length(distinct(local.rrset_identity_keys))
      error_message = "RRSet definitions must be unique by normalized type and name."
    }
  }
}
