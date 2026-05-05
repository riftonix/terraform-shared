variable "project_id" {
  description = "Selectel project ID associated with the DNS zone and RRSets."
  type        = string
}

variable "zone_id" {
  description = "Selectel DNS zone ID where records will be managed."
  type        = string
}

variable "zone_name" {
  description = "DNS zone name. Relative record names are resolved against this zone; use @ for the zone apex."
  type        = string

  validation {
    condition     = length(trimspace(var.zone_name)) > 0
    error_message = "zone_name must not be empty."
  }
}

variable "default_ttl" {
  description = "Default TTL for records when ttl is omitted."
  type        = number
  default     = 300

  validation {
    condition     = var.default_ttl >= 60 && var.default_ttl <= 604800
    error_message = "default_ttl must be between 60 and 604800 seconds."
  }
}

variable "a_records" {
  description = "A records keyed by record name."
  type = map(object({
    addresses = list(string)
    ttl       = optional(number)
    comment   = optional(string)
    disabled  = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for record in values(var.a_records) : length(record.addresses) > 0
    ])
    error_message = "Each A RRSet must contain at least one address."
  }

  validation {
    condition = alltrue([
      for record in values(var.a_records) : record.ttl == null ? true : record.ttl >= 60 && record.ttl <= 604800
    ])
    error_message = "A record ttl must be between 60 and 604800 seconds."
  }
}

variable "aaaa_records" {
  description = "AAAA records keyed by record name."
  type = map(object({
    addresses = list(string)
    ttl       = optional(number)
    comment   = optional(string)
    disabled  = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for record in values(var.aaaa_records) : length(record.addresses) > 0
    ])
    error_message = "Each AAAA RRSet must contain at least one address."
  }

  validation {
    condition = alltrue([
      for record in values(var.aaaa_records) : record.ttl == null ? true : record.ttl >= 60 && record.ttl <= 604800
    ])
    error_message = "AAAA record ttl must be between 60 and 604800 seconds."
  }
}

variable "cname_records" {
  description = "CNAME records keyed by record name. CNAME has a single target by DNS design."
  type = map(object({
    target   = string
    ttl      = optional(number)
    comment  = optional(string)
    disabled = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for record in values(var.cname_records) : record.ttl == null ? true : record.ttl >= 60 && record.ttl <= 604800
    ])
    error_message = "CNAME record ttl must be between 60 and 604800 seconds."
  }
}

variable "alias_records" {
  description = "ALIAS records keyed by record name."
  type = map(object({
    target   = string
    ttl      = optional(number)
    comment  = optional(string)
    disabled = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for record in values(var.alias_records) : record.ttl == null ? true : record.ttl >= 60 && record.ttl <= 604800
    ])
    error_message = "ALIAS record ttl must be between 60 and 604800 seconds."
  }
}

variable "txt_records" {
  description = "TXT records keyed by record name. Values are quoted automatically when omitted."
  type = map(object({
    values   = list(string)
    ttl      = optional(number)
    comment  = optional(string)
    disabled = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for record in values(var.txt_records) : length(record.values) > 0
    ])
    error_message = "Each TXT RRSet must contain at least one value."
  }

  validation {
    condition = alltrue([
      for record in values(var.txt_records) : record.ttl == null ? true : record.ttl >= 60 && record.ttl <= 604800
    ])
    error_message = "TXT record ttl must be between 60 and 604800 seconds."
  }
}

variable "mx_records" {
  description = "MX records keyed by record name."
  type = map(object({
    records = list(object({
      priority = number
      host     = string
    }))
    ttl      = optional(number)
    comment  = optional(string)
    disabled = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for record in values(var.mx_records) : length(record.records) > 0
    ])
    error_message = "Each MX RRSet must contain at least one record."
  }

  validation {
    condition = alltrue([
      for record in values(var.mx_records) : record.ttl == null ? true : record.ttl >= 60 && record.ttl <= 604800
    ])
    error_message = "MX record ttl must be between 60 and 604800 seconds."
  }
}

variable "ns_records" {
  description = "NS records keyed by subdomain name. Apex NS is created by Selectel automatically and cannot be managed."
  type = map(object({
    nameservers = list(string)
    ttl         = optional(number)
    comment     = optional(string)
    disabled    = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for record in values(var.ns_records) : length(record.nameservers) > 0
    ])
    error_message = "Each NS RRSet must contain at least one nameserver."
  }

  validation {
    condition = alltrue([
      for name in keys(var.ns_records) : name != "@"
    ])
    error_message = "Apex NS RRSet cannot be managed; Selectel creates it automatically."
  }

  validation {
    condition = alltrue([
      for record in values(var.ns_records) : record.ttl == null ? true : record.ttl >= 60 && record.ttl <= 604800
    ])
    error_message = "NS record ttl must be between 60 and 604800 seconds."
  }
}

variable "srv_records" {
  description = "SRV records keyed by service name, for example _sip._tcp.example.com."
  type = map(object({
    records = list(object({
      priority = number
      weight   = number
      port     = number
      target   = string
    }))
    ttl      = optional(number)
    comment  = optional(string)
    disabled = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for record in values(var.srv_records) : length(record.records) > 0
    ])
    error_message = "Each SRV RRSet must contain at least one record."
  }

  validation {
    condition = alltrue([
      for record in values(var.srv_records) : record.ttl == null ? true : record.ttl >= 60 && record.ttl <= 604800
    ])
    error_message = "SRV record ttl must be between 60 and 604800 seconds."
  }
}

variable "sshfp_records" {
  description = "SSHFP records keyed by record name."
  type = map(object({
    records = list(object({
      algorithm        = number
      fingerprint_type = number
      fingerprint      = string
    }))
    ttl      = optional(number)
    comment  = optional(string)
    disabled = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for record in values(var.sshfp_records) : length(record.records) > 0
    ])
    error_message = "Each SSHFP RRSet must contain at least one record."
  }

  validation {
    condition = alltrue(flatten([
      for record in values(var.sshfp_records) : [
        for item in record.records : item.algorithm >= 1 && item.algorithm <= 4
      ]
    ]))
    error_message = "SSHFP algorithm must be between 1 and 4."
  }

  validation {
    condition = alltrue(flatten([
      for record in values(var.sshfp_records) : [
        for item in record.records : item.fingerprint_type >= 1 && item.fingerprint_type <= 2
      ]
    ]))
    error_message = "SSHFP fingerprint_type must be between 1 and 2."
  }

  validation {
    condition = alltrue([
      for record in values(var.sshfp_records) : record.ttl == null ? true : record.ttl >= 60 && record.ttl <= 604800
    ])
    error_message = "SSHFP record ttl must be between 60 and 604800 seconds."
  }
}

variable "caa_records" {
  description = "CAA records keyed by record name. Values are quoted automatically when omitted."
  type = map(object({
    records = list(object({
      flag  = number
      tag   = string
      value = string
    }))
    ttl      = optional(number)
    comment  = optional(string)
    disabled = optional(bool, false)
  }))
  default = {}

  validation {
    condition = alltrue([
      for record in values(var.caa_records) : length(record.records) > 0
    ])
    error_message = "Each CAA RRSet must contain at least one record."
  }

  validation {
    condition = alltrue(flatten([
      for record in values(var.caa_records) : [
        for item in record.records : item.flag >= 0 && item.flag <= 128
      ]
    ]))
    error_message = "CAA flag must be between 0 and 128."
  }

  validation {
    condition = alltrue(flatten([
      for record in values(var.caa_records) : [
        for item in record.records : contains(["issue", "issuewild", "iodef", "auth", "path", "policy"], item.tag)
      ]
    ]))
    error_message = "CAA tag must be one of: issue, issuewild, iodef, auth, path, policy."
  }

  validation {
    condition = alltrue([
      for record in values(var.caa_records) : record.ttl == null ? true : record.ttl >= 60 && record.ttl <= 604800
    ])
    error_message = "CAA record ttl must be between 60 and 604800 seconds."
  }
}

variable "rrsets" {
  description = "Raw Selectel DNS RRSets for unsupported edge cases. Prefer typed variables above for normal records."
  type = map(object({
    name    = string
    type    = string
    ttl     = number
    comment = optional(string)
    records = set(object({
      content  = string
      disabled = optional(bool, false)
    }))
  }))
  default = {}

  validation {
    condition = alltrue([
      for rrset in values(var.rrsets) :
      contains(["A", "AAAA", "TXT", "CNAME", "MX", "NS", "SRV", "SSHFP", "ALIAS", "CAA"], upper(rrset.type))
    ])
    error_message = "RRSet type must be one of: A, AAAA, TXT, CNAME, MX, NS, SRV, SSHFP, ALIAS, CAA."
  }

  validation {
    condition = alltrue([
      for rrset in values(var.rrsets) :
      rrset.ttl >= 60 && rrset.ttl <= 604800
    ])
    error_message = "RRSet ttl must be between 60 and 604800 seconds."
  }

  validation {
    condition = alltrue([
      for rrset in values(var.rrsets) :
      length(rrset.records) > 0
    ])
    error_message = "Each raw RRSet must contain at least one record."
  }

  validation {
    condition = alltrue([
      for rrset in values(var.rrsets) :
      !(upper(rrset.type) == "NS" && rrset.name == "@")
    ])
    error_message = "Apex NS RRSet cannot be managed; Selectel creates it automatically."
  }

}
