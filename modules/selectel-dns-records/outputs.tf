output "rrsets" {
  description = "Managed RRSets keyed by generated typed keys or raw rrsets keys."
  value = {
    for key, rrset in selectel_domains_rrset_v2.this : key => {
      id         = rrset.id
      name       = rrset.name
      type       = rrset.type
      ttl        = rrset.ttl
      records    = rrset.records
      managed_by = rrset.managed_by
    }
  }
}
