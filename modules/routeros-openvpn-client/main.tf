locals {
  ovpn_file_name                          = "${var.name}.ovpn"
  routing_table                           = coalesce(try(var.egress.routing_table, null), "to-${var.egress.name}")
  gateway                                 = coalesce(try(var.egress.gateway, null), var.name)
  comment                                 = coalesce(var.comment, try(var.egress.comment, null), "OpenVPN client ${var.name}")
  ovpn_credentials                        = var.ovpn_user != "" || var.ovpn_password != "" ? " ovpn-user=\"${var.ovpn_user}\" ovpn-password=\"${var.ovpn_password}\"" : ""
  key_passphrase                          = var.key_passphrase != "" ? " key-passphrase=\"${var.key_passphrase}\"" : ""
  skip_cert_import                        = var.skip_cert_import ? "yes" : "no"
  verify_certificate                      = var.verify_server_certificate ? "yes" : "no"
  imported_certificate                    = var.set_imported_certificate ? "yes" : "no"
  import_command_line                     = "/interface ovpn-client/import-ovpn-configuration file-name=\"${routeros_file.ovpn_config.name}\"${local.ovpn_credentials}${local.key_passphrase} skip-cert-import=${local.skip_cert_import}"
  import_command_line_without_cert_import = "/interface ovpn-client/import-ovpn-configuration file-name=\"${routeros_file.ovpn_config.name}\"${local.ovpn_credentials}${local.key_passphrase} skip-cert-import=yes"
  script_comment                          = replace(local.comment, "\"", "'")
}

resource "routeros_file" "ovpn_config" {
  name     = local.ovpn_file_name
  contents = file(var.ovpn_config_path)
}

resource "routeros_system_script" "import_ovpn" {
  name    = "tf-import-${var.name}"
  comment = local.comment
  policy  = ["read", "write", "sensitive"]

  source = <<-EOS
    :foreach item in=[/interface ovpn-client find] do={
      :local itemName [/interface ovpn-client get $item name]
      :if ([:pick $itemName 0 11] = "ovpn-import") do={
        /interface ovpn-client remove $item
      }
    }

    ${local.import_command_line}

    :delay 5s

    :local target ""
    :foreach item in=[/interface ovpn-client find] do={
      :local itemName [/interface ovpn-client get $item name]
      :if ([:len $target] = 0) do={
        :if ([:pick $itemName 0 11] = "ovpn-import") do={
          :set target $item
        }
      }
    }

    :if ([:len $target] = 0) do={
      :foreach item in=[/interface ovpn-client find] do={
        :local itemName [/interface ovpn-client get $item name]
        :if ($itemName = "${var.name}") do={
          :set target $item
        }
      }
    }

    :if ([:len $target] = 0) do={
      :if ("${local.skip_cert_import}" = "no") do={
        ${local.import_command_line_without_cert_import}

        :delay 5s

        :foreach item in=[/interface ovpn-client find] do={
          :local itemName [/interface ovpn-client get $item name]
          :if ([:len $target] = 0) do={
            :if ([:pick $itemName 0 11] = "ovpn-import") do={
              :set target $item
            }
          }
        }

        :if ([:len $target] = 0) do={
          :foreach item in=[/interface ovpn-client find] do={
            :local itemName [/interface ovpn-client get $item name]
            :if ($itemName = "${var.name}") do={
              :set target $item
            }
          }
        }
      }
    }

    :if ([:len $target] = 0) do={
      :error "OpenVPN client ${var.name} was not imported"
    }

    :local clientCert ""
    :foreach item in=[/certificate find] do={
      :local certName [/certificate get $item name]
      :if ([:find $certName "cert_ovpn-import"] = 0) do={
        :set clientCert $certName
      }
    }

    :foreach item in=[/interface ovpn-client find where name="${var.name}"] do={
      :if ($item != $target) do={
        /interface ovpn-client remove $item
      }
    }

    /interface ovpn-client set $target name="${var.name}" comment="${local.script_comment}" verify-server-certificate=${local.verify_certificate} disabled=no
	    :if (("${local.imported_certificate}" = "yes") && ([:len $clientCert] > 0)) do={
	      /interface ovpn-client set $target certificate=$clientCert
	    }
	    :if ("${local.imported_certificate}" = "no") do={
	      /interface ovpn-client set $target certificate=none
	    }
  EOS

  launch_trigger = sha1(jsonencode({
    file                      = filesha256(var.ovpn_config_path)
    name                      = var.name
    skip_cert_import          = var.skip_cert_import
    set_imported_certificate  = var.set_imported_certificate
    verify_server_certificate = var.verify_server_certificate
    version                   = 13
  }))

  depends_on = [routeros_file.ovpn_config]
}

resource "routeros_ip_firewall_nat" "egress_nat" {
  count = var.create_nat ? 1 : 0

  action        = "masquerade"
  chain         = "srcnat"
  out_interface = var.name
  comment       = "${local.comment} NAT"

  depends_on = [routeros_system_script.import_ovpn]
}
