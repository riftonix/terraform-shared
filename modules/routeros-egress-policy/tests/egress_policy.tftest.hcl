mock_provider "routeros" {}

variables {
  sources = {
    alice = {
      in_interface   = "wg-clients"
      src_address    = "172.16.20.2/32"
      allowed_egress = ["ru", "kz", "crpt"]
    }
    bob = {
      in_interface   = "wg-clients"
      src_address    = "172.16.20.3/32"
      allowed_egress = ["ru", "kz"]
    }
    carol = {
      in_interface = "wg-clients"
      src_address  = "172.16.20.4/32"
    }
  }

  default_egress = "ru"

  egresses = {
    ru = {}
    kz = {
      routing_table       = "to-kz"
      gateway             = "172.18.0.6"
      destination_domains = ["example.com", "sub.example.org"]
    }
    crpt = {
      routing_table        = "to-crpt"
      gateway              = "172.18.0.2"
      destination_prefixes = ["10.0.0.0/8"]
      dns_resolver = {
        domains = [
          "crpt.local",
          "crpt.tech",
          "crpt.ru",
          "crptech.ru",
          "crpt.cloud",
          "crpt.intranet",
          "ittds.tech",
          "trekmark.ru",
          "crpt.team",
        ]
        servers = ["10.77.103.241", "10.77.103.242"]
      }
    }
  }
}

run "layer7_regexp_for_crpt_domains" {
  command = plan

  assert {
    condition     = routeros_ip_firewall_layer7_protocol.dns_resolver["crpt"].name == "egress-crpt-dns"
    error_message = "The layer7 protocol must be named egress-<name>-dns."
  }

  assert {
    condition     = routeros_ip_firewall_layer7_protocol.dns_resolver["crpt"].regexp == "(\\x04crpt\\x05local|\\x04crpt\\x04tech|\\x04crpt\\x02ru|\\x07crptech\\x02ru|\\x04crpt\\x05cloud|\\x04crpt\\x08intranet|\\x05ittds\\x04tech|\\x08trekmark\\x02ru|\\x04crpt\\x04team)"
    error_message = "The layer7 regexp must encode the domains in DNS wire format."
  }

  assert {
    condition     = keys(routeros_ip_firewall_layer7_protocol.dns_resolver) == ["crpt"]
    error_message = "Only egresses with dns_resolver get a layer7 protocol."
  }
}

run "layer7_length_byte_in_hex" {
  command = plan

  variables {
    egresses = {
      ru = {}
      long = {
        dns_resolver = {
          domains = ["abcdefghijklmnopqrstuv.ru"]
          servers = ["192.0.2.1"]
        }
      }
    }
  }

  assert {
    condition     = routeros_ip_firewall_layer7_protocol.dns_resolver["long"].regexp == "(\\x16abcdefghijklmnopqrstuv\\x02ru)"
    error_message = "The length byte must be two lowercase hex digits."
  }
}

run "dstnat_rules_per_allowed_source_and_server" {
  command = plan

  assert {
    condition     = toset(keys(routeros_ip_firewall_nat.dns_resolver)) == toset(["crpt-alice-0", "crpt-alice-1", "crpt-carol-0", "crpt-carol-1"])
    error_message = "There must be one dstnat rule per allowed source and server, and none for sources without the egress."
  }

  assert {
    condition = alltrue([
      for rule in routeros_ip_firewall_nat.dns_resolver :
      rule.chain == "dstnat" && rule.action == "dst-nat" && rule.protocol == "udp" && rule.dst_port == "53"
      && rule.dst_address_type == "local" && rule.in_interface == "wg-clients" && rule.layer7_protocol == "egress-crpt-dns"
      && rule.to_ports == "53" && rule.comment == "Egress crpt DNS resolver"
    ])
    error_message = "Each dstnat rule must redirect UDP DNS queries to the router matching the layer7 protocol."
  }

  assert {
    condition = (
      routeros_ip_firewall_nat.dns_resolver["crpt-alice-0"].src_address == "172.16.20.2"
      && routeros_ip_firewall_nat.dns_resolver["crpt-alice-0"].to_addresses == "10.77.103.241"
      && routeros_ip_firewall_nat.dns_resolver["crpt-alice-0"].per_connection_classifier == "both-addresses-and-ports:2/0"
      && routeros_ip_firewall_nat.dns_resolver["crpt-alice-1"].to_addresses == "10.77.103.242"
      && routeros_ip_firewall_nat.dns_resolver["crpt-alice-1"].per_connection_classifier == "both-addresses-and-ports:2/1"
      && routeros_ip_firewall_nat.dns_resolver["crpt-carol-1"].src_address == "172.16.20.4"
    )
    error_message = "Each rule must carry its source address, its server and the PCC share of that server."
  }
}

run "no_pcc_with_one_server" {
  command = plan

  variables {
    egresses = {
      ru = {}
      crpt = {
        routing_table = "to-crpt"
        gateway       = "172.18.0.2"
        dns_resolver = {
          domains = ["crpt.ru"]
          servers = ["10.77.103.241"]
        }
      }
    }
  }

  assert {
    condition     = toset(keys(routeros_ip_firewall_nat.dns_resolver)) == toset(["crpt-alice-0", "crpt-carol-0"])
    error_message = "With one server there must be one rule per allowed source."
  }

  assert {
    condition     = alltrue([for rule in routeros_ip_firewall_nat.dns_resolver : rule.per_connection_classifier == null])
    error_message = "With one server the rules must not use PCC."
  }
}

run "no_redirection_without_dns_resolver" {
  command = plan

  variables {
    egresses = {
      ru = {}
      kz = {
        routing_table       = "to-kz"
        gateway             = "172.18.0.6"
        destination_domains = ["example.com"]
      }
    }
  }

  assert {
    condition     = length(routeros_ip_firewall_layer7_protocol.dns_resolver) == 0 && length(routeros_ip_firewall_nat.dns_resolver) == 0
    error_message = "Without dns_resolver there must be no layer7 protocol and no dstnat rule."
  }
}

run "destination_domains_records" {
  command = plan

  assert {
    condition     = toset(keys(routeros_ip_dns_record.egress_name)) == toset(["kz-example-com", "kz-sub-example-org"])
    error_message = "destination_domains must produce the record keys of dns_names, and dns_resolver must add no record."
  }

  assert {
    condition = (
      routeros_ip_dns_record.egress_name["kz-sub-example-org"].name == "sub.example.org"
      && routeros_ip_dns_record.egress_name["kz-sub-example-org"].match_subdomain == true
      && routeros_ip_dns_record.egress_name["kz-sub-example-org"].type == "FWD"
      && routeros_ip_dns_record.egress_name["kz-sub-example-org"].forward_to == "1.1.1.1"
      && routeros_ip_dns_record.egress_name["kz-sub-example-org"].address_list == "egress-kz"
      && routeros_ip_dns_record.egress_name["kz-sub-example-org"].disabled == false
      && routeros_ip_dns_record.egress_name["kz-sub-example-org"].comment == "Egress kz DNS address-list"
    )
    error_message = "destination_domains must produce the record attributes of dns_names."
  }

  assert {
    condition     = output.destination_address_lists == { kz = "egress-kz", crpt = "egress-crpt" }
    error_message = "dns_resolver must not change the address lists."
  }

  assert {
    condition     = toset(keys(routeros_ip_firewall_addr_list.destination)) == toset(["crpt-10-0-0-0_8"])
    error_message = "dns_resolver must add nothing to the address list."
  }
}

run "destination_domains_upstream" {
  command = plan

  variables {
    destination_domains_upstream = ["9.9.9.9", "1.1.1.1"]
  }

  assert {
    condition     = alltrue([for record in routeros_ip_dns_record.egress_name : record.forward_to == "9.9.9.9"])
    error_message = "The records must forward to the first upstream."
  }
}

run "reject_empty_domains" {
  command = plan

  variables {
    egresses = {
      ru = {}
      crpt = {
        dns_resolver = {
          domains = []
          servers = ["10.77.103.241"]
        }
      }
    }
  }

  expect_failures = [var.egresses]
}

run "reject_empty_servers" {
  command = plan

  variables {
    egresses = {
      ru = {}
      crpt = {
        dns_resolver = {
          domains = ["crpt.ru"]
          servers = []
        }
      }
    }
  }

  expect_failures = [var.egresses]
}

run "reject_server_with_prefix_length" {
  command = plan

  variables {
    egresses = {
      ru = {}
      crpt = {
        dns_resolver = {
          domains = ["crpt.ru"]
          servers = ["10.77.103.241/32"]
        }
      }
    }
  }

  expect_failures = [var.egresses]
}

run "reject_uppercase_domain" {
  command = plan

  variables {
    egresses = {
      ru = {}
      crpt = {
        dns_resolver = {
          domains = ["CRPT.ru"]
          servers = ["10.77.103.241"]
        }
      }
    }
  }

  expect_failures = [var.egresses]
}
