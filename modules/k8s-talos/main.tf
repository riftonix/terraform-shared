resource "talos_machine_secrets" "this" {
  talos_version = var.talos_version
}

locals {
  control_plane_nodes = [
    for name in sort(keys(var.control_plane_nodes_map)) : merge(
      {
        name = name
      },
      var.control_plane_defaults,
      var.control_plane_nodes_map[name]
    )
  ]

  worker_nodes_map_merged = length(var.worker_node_maps) > 0 ? merge(var.worker_node_maps...) : {}

  worker_nodes = [
    for name in sort(keys(local.worker_nodes_map_merged)) : merge(
      {
        name = name
      },
      var.worker_defaults,
      local.worker_nodes_map_merged[name]
    )
  ]

  control_plane_nodes_by_name = {
    for node in local.control_plane_nodes : node.name => merge(node, {
      endpoint = try(node.endpoint, node.node)
    })
  }

  worker_nodes_by_name = {
    for node in local.worker_nodes : node.name => merge(node, {
      endpoint = try(node.endpoint, node.node)
    })
  }

  rollout_control_plane_nodes_by_name = var.rollout_control_plane_names == null ? local.control_plane_nodes_by_name : {
    for name, node in local.control_plane_nodes_by_name : name => node
    if contains(var.rollout_control_plane_names, name)
  }

  rollout_worker_nodes_by_name = var.rollout_worker_names == null ? local.worker_nodes_by_name : {
    for name, node in local.worker_nodes_by_name : name => node
    if contains(var.rollout_worker_names, name)
  }

  cluster_endpoint_host = coalesce(
    var.cluster_endpoint_host,
    try(local.control_plane_nodes[0].endpoint, local.control_plane_nodes[0].node)
  )

  cluster_endpoint = "https://${local.cluster_endpoint_host}:${var.cluster_endpoint_port}"

  bootstrap_node = coalesce(var.bootstrap_node, local.control_plane_nodes[0].node)
  bootstrap_endpoint = coalesce(
    var.bootstrap_endpoint,
    try(local.control_plane_nodes[0].endpoint, local.control_plane_nodes[0].node)
  )

  talosconfig_endpoints = length(var.talosconfig_endpoints) > 0 ? var.talosconfig_endpoints : [
    for node in local.control_plane_nodes : try(node.endpoint, node.node)
  ]

  base_cert_sans = distinct(compact(concat(
    [local.cluster_endpoint_host],
    var.additional_api_server_cert_sans,
    [for node in local.control_plane_nodes : node.node],
    [for node in local.control_plane_nodes : try(node.endpoint, node.node)]
  )))

  control_plane_base_patches = {
    for name, node in local.control_plane_nodes_by_name : name => yamlencode({
      machine = merge(
        {
          certSANs = local.base_cert_sans
        },
        node.install_disk != null ? {
          install = {
            disk = node.install_disk
          }
        } : {},
        length(node.labels) > 0 ? {
          nodeLabels = node.labels
        } : {},
        length(node.taints) > 0 ? {
          kubelet = {
            extraConfig = {
              registerWithTaints = [
                for taint in node.taints : {
                  key    = taint.key
                  value  = taint.value
                  effect = taint.effect
                }
              ]
            }
          }
        } : {}
      )
      cluster = {
        allowSchedulingOnControlPlanes = var.control_plane_allow_schedule || length(local.worker_nodes) == 0
      }
    })
  }

  worker_base_patches = {
    for name, node in local.worker_nodes_by_name : name => yamlencode({
      machine = merge(
        {
          certSANs = local.base_cert_sans
        },
        node.install_disk != null ? {
          install = {
            disk = node.install_disk
          }
        } : {},
        length(node.labels) > 0 ? {
          nodeLabels = node.labels
        } : {},
        length(node.taints) > 0 ? {
          kubelet = {
            extraConfig = {
              registerWithTaints = [
                for taint in node.taints : {
                  key    = taint.key
                  value  = taint.value
                  effect = taint.effect
                }
              ]
            }
          }
        } : {}
      )
    })
  }
}

check "control_plane_nodes_present" {
  assert {
    condition     = length(local.control_plane_nodes) > 0
    error_message = "At least one control-plane node must be provided via control_plane_nodes_map."
  }
}

data "talos_machine_configuration" "control_plane" {
  for_each           = local.control_plane_nodes_by_name
  cluster_name       = var.cluster_name
  cluster_endpoint   = local.cluster_endpoint
  machine_type       = "controlplane"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  docs               = false
  examples           = false

  config_patches = concat(
    [local.control_plane_base_patches[each.key]],
    var.control_plane_config_patches,
    each.value.config_patches
  )
}

data "talos_machine_configuration" "worker" {
  for_each           = local.worker_nodes_by_name
  cluster_name       = var.cluster_name
  cluster_endpoint   = local.cluster_endpoint
  machine_type       = "worker"
  machine_secrets    = talos_machine_secrets.this.machine_secrets
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version
  docs               = false
  examples           = false

  config_patches = concat(
    [local.worker_base_patches[each.key]],
    var.worker_config_patches,
    each.value.config_patches
  )
}

resource "talos_machine_configuration_apply" "control_plane" {
  for_each = local.rollout_control_plane_nodes_by_name

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.control_plane[each.key].machine_configuration
  node                        = each.value.node
  endpoint                    = each.value.endpoint
  apply_mode                  = var.apply_mode
}

resource "talos_machine_configuration_apply" "worker" {
  for_each = local.rollout_worker_nodes_by_name

  client_configuration        = talos_machine_secrets.this.client_configuration
  machine_configuration_input = data.talos_machine_configuration.worker[each.key].machine_configuration
  node                        = each.value.node
  endpoint                    = each.value.endpoint
  apply_mode                  = var.apply_mode
}

resource "talos_machine_bootstrap" "this" {
  depends_on = [
    talos_machine_configuration_apply.control_plane,
    talos_machine_configuration_apply.worker,
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.bootstrap_node
  endpoint             = local.bootstrap_endpoint
}

data "talos_client_configuration" "this" {
  cluster_name         = var.cluster_name
  client_configuration = talos_machine_secrets.this.client_configuration
  endpoints            = local.talosconfig_endpoints
}

resource "talos_cluster_kubeconfig" "this" {
  depends_on = [
    talos_machine_bootstrap.this,
  ]

  client_configuration = talos_machine_secrets.this.client_configuration
  node                 = local.bootstrap_node
  endpoint             = local.bootstrap_endpoint
}

locals {
  kubeconfig_server_host = coalesce(var.kubeconfig_server_host, local.cluster_endpoint_host)

  kubeconfig = replace(
    talos_cluster_kubeconfig.this.kubeconfig_raw,
    local.cluster_endpoint,
    "https://${local.kubeconfig_server_host}:${var.cluster_endpoint_port}"
  )

  kubeconfig_data = {
    host                   = "https://${local.kubeconfig_server_host}:${var.cluster_endpoint_port}"
    cluster_name           = var.cluster_name
    cluster_ca_certificate = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.ca_certificate)
    client_certificate     = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_certificate)
    client_key             = base64decode(talos_cluster_kubeconfig.this.kubernetes_client_configuration.client_key)
  }
}
