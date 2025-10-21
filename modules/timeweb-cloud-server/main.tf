locals {
  preset_id       = try(data.twc_presets.this[0].id, null)
  software_id     = try(data.twc_software.this[0].id, null)
  image_id        = try(data.twc_image.this[0].id, null)
  os_id           = try(try(data.twc_os.this[0].id, data.twc_software.this[0].os[0].id), null)
  project_id      = try(data.twc_projects.this[0].id, null)
  configurator_id = try(data.twc_configurator.this[0].id, null)
  ssh_keys_ids    = concat([for key in data.twc_ssh_keys.this : key.id], [for key in twc_ssh_key.this : key.id])
  cloud_init      = var.cloud_init == null ? "" : templatefile(var.cloud_init.file, local.cloud_init_vars)
  cloud_init_vars = try(var.cloud_init.vars == null ? {} : var.cloud_init.vars, {})
  ssh_keys_paths  = try({ for key, value in var.ssh_keys_paths : key => value }, null)
}

data "twc_os" "this" {
  count = var.os != null ? 1 : 0

  name    = var.os.name
  version = var.os.version
}

data "twc_image" "this" {
  count = var.image_name != null ? 1 : 0

  name     = var.image_name
  location = var.location
}

data "twc_software" "this" {
  count = var.software != null ? 1 : 0

  name = var.software.name
  os {
    family  = var.software.os_family
    name    = var.software.os_name
    version = var.software.os_version
  }
}


data "twc_presets" "this" {
  count = var.preset != null ? 1 : 0

  location      = var.location
  cpu_frequency = var.cpu_frequency

  cpu  = var.preset.cpu
  ram  = 1024 * var.preset.ram
  disk = 1024 * var.preset.disk

  dynamic "price_filter" {
    for_each = var.preset.price == null ? [] : [var.preset.price]

    content {
      from = price_filter.value.min
      to   = price_filter.value.max
    }
  }
}

data "twc_ssh_keys" "this" {
  for_each = var.ssh_keys == null ? [] : toset(var.ssh_keys)

  name = each.key
}

data "twc_configurator" "this" {
  count = var.configurator != null ? 1 : 0

  location      = var.location
  cpu_frequency = var.cpu_frequency
}

data "twc_projects" "this" {
  count = var.project_name != null ? 1 : 0
  name  = var.project_name
}

resource "twc_ssh_key" "this" {
  count = local.ssh_keys_paths != null ? length(local.ssh_keys_paths) : 0

  name = local.ssh_keys_paths[count.index].name
  body = file(local.ssh_keys_paths[count.index].path)
}

resource "twc_server" "this" {
  name = var.name

  availability_zone = var.availability_zone

  preset_id = local.preset_id

  image_id    = local.image_id
  os_id       = local.os_id
  software_id = local.software_id
  project_id  = local.project_id

  ssh_keys_ids = local.ssh_keys_ids

  cloud_init = local.cloud_init

  dynamic "configuration" {
    for_each = var.configurator == null ? [] : [var.configurator]

    content {
      configurator_id = local.configurator_id

      cpu  = configuration.value.cpu
      ram  = 1024 * configuration.value.ram
      disk = 1024 * configuration.value.disk
    }
  }

  lifecycle {
    ignore_changes = [ssh_keys_ids]
  }
}

resource "twc_floating_ip" "this" {
  count = var.create_floating_ip ? 1 : 0

  availability_zone = var.availability_zone

  resource {
    type = "server"
    id   = twc_server.this.id
  }
}
