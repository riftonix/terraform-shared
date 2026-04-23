output "ipv4_prefixes" {
  description = "Merged, deduplicated and sorted IPv4 announced prefixes for all requested resources"
  value       = local.ipv4_prefixes
}
