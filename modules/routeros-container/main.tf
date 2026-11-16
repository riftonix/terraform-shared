locals {
  interface_name = coalesce(var.network.interface_name, "veth-${var.name}")
  router_host    = split("/", var.network.router_address)[0]
  container_host = split("/", var.network.container_address)[0]
  comment        = coalesce(var.comment, "Container ${var.name}")
  env_keys       = nonsensitive(toset(keys(var.envs)))
  has_envs       = nonsensitive(length(var.envs)) > 0
  egress_routing = var.egress == null ? null : coalesce(var.egress.routing_table, "to-${var.egress.name}")
}

resource "routeros_interface_veth" "this" {
  name    = local.interface_name
  address = [var.network.container_address]
  gateway = local.router_host
  comment = local.comment
}

resource "routeros_ip_address" "this" {
  address   = var.network.router_address
  interface = routeros_interface_veth.this.name
  comment   = local.comment
}

resource "routeros_container_envs" "this" {
  for_each = local.env_keys

  name  = var.name
  key   = each.key
  value = var.envs[each.key]
}

resource "routeros_container" "this" {
  remote_image          = var.remote_image
  root_dir              = var.root_dir
  interface             = routeros_interface_veth.this.name
  envlist               = local.has_envs ? var.name : null
  devices               = length(var.devices) > 0 ? var.devices : null
  dns                   = var.dns
  memory_high           = var.memory_high
  logging               = var.logging
  check_certificate     = var.check_certificate
  start_on_boot         = var.start_on_boot
  auto_restart_interval = var.auto_restart_interval
  running               = var.start_on_create
  comment               = local.comment

  depends_on = [routeros_container_envs.this]

  lifecycle {
    ignore_changes = [running]
  }
}
