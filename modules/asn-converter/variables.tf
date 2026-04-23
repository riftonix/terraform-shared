variable "resources" {
  description = "List of RIPE resources, for example ASNs like AS44907"
  type        = list(string)
  default     = []
}

variable "base_url" {
  description = "Base URL for the RIPE announced-prefixes endpoint"
  type        = string
  default     = "https://stat.ripe.net/data/announced-prefixes/data.json"
}
