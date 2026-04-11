<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_talos"></a> [talos](#requirement\_talos) | >= 0.9.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_talos"></a> [talos](#provider\_talos) | >= 0.9.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [talos_cluster_kubeconfig.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/cluster_kubeconfig) | resource |
| [talos_machine_bootstrap.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_bootstrap) | resource |
| [talos_machine_configuration_apply.control_plane](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_configuration_apply.worker](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_configuration_apply) | resource |
| [talos_machine_secrets.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/resources/machine_secrets) | resource |
| [talos_client_configuration.this](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/client_configuration) | data source |
| [talos_machine_configuration.control_plane](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/machine_configuration) | data source |
| [talos_machine_configuration.worker](https://registry.terraform.io/providers/siderolabs/talos/latest/docs/data-sources/machine_configuration) | data source |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_additional_api_server_cert_sans"></a> [additional\_api\_server\_cert\_sans](#input\_additional\_api\_server\_cert\_sans) | Additional SAN values added to Talos machine certSANs patch. | `list(string)` | `[]` | no |
| <a name="input_apply_mode"></a> [apply\_mode](#input\_apply\_mode) | Apply mode for talos_machine_configuration_apply. | `string` | `"auto"` | no |
| <a name="input_bootstrap_endpoint"></a> [bootstrap\_endpoint](#input\_bootstrap\_endpoint) | Talos API endpoint for bootstrap node. If null, first control-plane endpoint is used. | `string` | `null` | no |
| <a name="input_bootstrap_node"></a> [bootstrap\_node](#input\_bootstrap\_node) | Node address for talos bootstrap action. If null, first control-plane node is used. | `string` | `null` | no |
| <a name="input_cluster_endpoint_host"></a> [cluster\_endpoint\_host](#input\_cluster\_endpoint\_host) | Kubernetes API endpoint host (IP/DNS). If null, first control-plane endpoint is used. | `string` | `null` | no |
| <a name="input_cluster_endpoint_port"></a> [cluster\_endpoint\_port](#input\_cluster\_endpoint\_port) | Kubernetes API endpoint port. | `number` | `6443` | no |
| <a name="input_cluster_name"></a> [cluster\_name](#input\_cluster\_name) | Talos/Kubernetes cluster name. | `string` | n/a | yes |
| <a name="input_control_plane_allow_schedule"></a> [control\_plane\_allow\_schedule](#input\_control\_plane\_allow\_schedule) | Allow workload scheduling on control-plane nodes. | `bool` | `false` | no |
| <a name="input_control_plane_config_patches"></a> [control\_plane\_config\_patches](#input\_control\_plane\_config\_patches) | Extra config patches applied to all control-plane nodes. | `list(string)` | `[]` | no |
| <a name="input_control_plane_defaults"></a> [control\_plane\_defaults](#input\_control\_plane\_defaults) | Defaults applied to nodes from control_plane_nodes_map. | <pre>object({<br/>    install_disk   = optional(string)<br/>    labels         = optional(map(string), {})<br/>    taints         = optional(list(object({ key = string, value = string, effect = string })), [])<br/>    config_patches = optional(list(string), [])<br/>  })</pre> | <pre>{<br/>  "config_patches": [],<br/>  "install_disk": null,<br/>  "labels": {},<br/>  "taints": []<br/>}</pre> | no |
| <a name="input_control_plane_nodes_map"></a> [control\_plane\_nodes\_map](#input\_control\_plane\_nodes\_map) | Control-plane nodes as map keyed by node name. Works with any infra module output that follows this schema. | <pre>map(object({<br/>    name     = string<br/>    node     = string<br/>    endpoint = optional(string)<br/>    install_disk = optional(string)<br/>    labels       = optional(map(string), {})<br/>    taints = optional(list(object({<br/>      key    = string<br/>      value  = string<br/>      effect = string<br/>    })), [])<br/>    config_patches = optional(list(string), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_kubeconfig_server_host"></a> [kubeconfig\_server\_host](#input\_kubeconfig\_server\_host) | Host to write into kubeconfig server URL. If null, cluster_endpoint_host is used. | `string` | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version embedded into Talos machine configuration. | `string` | n/a | yes |
| <a name="input_talos_version"></a> [talos\_version](#input\_talos\_version) | Talos version used for generated machine configuration features. | `string` | n/a | yes |
| <a name="input_talosconfig_endpoints"></a> [talosconfig\_endpoints](#input\_talosconfig\_endpoints) | Talos API endpoints list to be written into talosconfig. If empty, all control-plane endpoints are used. | `list(string)` | `[]` | no |
| <a name="input_rollout_control_plane_names"></a> [rollout\_control\_plane\_names](#input\_rollout\_control\_plane\_names) | Control-plane rollout filter: null = all nodes, [] = no nodes, [names...] = selected nodes only. | `list(string)` | `null` | no |
| <a name="input_rollout_worker_names"></a> [rollout\_worker\_names](#input\_rollout\_worker\_names) | Worker rollout filter: null = all nodes, [] = no nodes, [names...] = selected nodes only. | `list(string)` | `null` | no |
| <a name="input_worker_config_patches"></a> [worker\_config\_patches](#input\_worker\_config\_patches) | Extra config patches applied to all worker nodes. | `list(string)` | `[]` | no |
| <a name="input_worker_defaults"></a> [worker\_defaults](#input\_worker\_defaults) | Defaults applied to nodes from worker_node_maps. | <pre>object({<br/>    install_disk   = optional(string)<br/>    labels         = optional(map(string), {})<br/>    taints         = optional(list(object({ key = string, value = string, effect = string })), [])<br/>    config_patches = optional(list(string), [])<br/>  })</pre> | <pre>{<br/>  "config_patches": [],<br/>  "install_disk": null,<br/>  "labels": {},<br/>  "taints": []<br/>}</pre> | no |
| <a name="input_worker_node_maps"></a> [worker\_node\_maps](#input\_worker\_node\_maps) | Worker nodes as list of maps keyed by node name (e.g., from one or many infra modules). | <pre>list(map(object({<br/>    name     = string<br/>    node     = string<br/>    endpoint = optional(string)<br/>    install_disk = optional(string)<br/>    labels       = optional(map(string), {})<br/>    taints = optional(list(object({<br/>      key    = string<br/>      value  = string<br/>      effect = string<br/>    })), [])<br/>    config_patches = optional(list(string), [])<br/>  })))</pre> | `[]` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_client_configuration"></a> [client\_configuration](#output\_client\_configuration) | Talos client configuration generated by talos_machine_secrets. |
| <a name="output_cluster_endpoint"></a> [cluster\_endpoint](#output\_cluster\_endpoint) | Talos cluster endpoint URL used for machine configuration generation. |
| <a name="output_control_plane_machine_configurations"></a> [control\_plane\_machine\_configurations](#output\_control\_plane\_machine\_configurations) | Generated machine configurations for control-plane nodes. |
| <a name="output_kubeconfig"></a> [kubeconfig](#output\_kubeconfig) | Generated kubeconfig with optionally rewritten server host. |
| <a name="output_kubeconfig_data"></a> [kubeconfig\_data](#output\_kubeconfig\_data) | Structured kubeconfig values for other providers. |
| <a name="output_machine_secrets"></a> [machine\_secrets](#output\_machine\_secrets) | Talos machine secrets generated by talos_machine_secrets. |
| <a name="output_talosconfig"></a> [talosconfig](#output\_talosconfig) | Generated talosconfig. |
| <a name="output_worker_machine_configurations"></a> [worker\_machine\_configurations](#output\_worker\_machine\_configurations) | Generated machine configurations for worker nodes. |
<!-- END_TF_DOCS -->

## How to apply patches (similar to terraform-hcloud-talos-main)

Patches are passed as YAML strings via variables:

- `control_plane_config_patches` — shared patches for all control-plane nodes
- `worker_config_patches` — shared patches for all worker nodes
- `control_plane_nodes_map["name"].config_patches` / `worker_node_maps[*]["name"].config_patches` — per-node patches

Example:

```hcl
module "k8s_talos" {
  source = "../../"

  cluster_name       = var.cluster_name
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  cluster_endpoint_host = var.cluster_endpoint_host

  control_plane_nodes_map = var.control_plane_nodes_map
  worker_node_maps        = var.worker_node_maps

  control_plane_config_patches = [
    file("${path.module}/patches/kubelet/control-plane.yaml"),
    file("${path.module}/patches/registries.yaml"),
  ]

  worker_config_patches = [
    file("${path.module}/patches/kubelet/worker.yaml"),
    file("${path.module}/patches/registries.yaml"),
  ]
}
```

A complete working example with patch files is available in `examples/base`:

- `examples/base/main.tf`
- `examples/base/patches/registries.yaml`
- `examples/base/patches/kubelet/control-plane.yaml`
- `examples/base/patches/kubelet/worker.yaml`

## Node input format (map-only)

This module accepts nodes **only** in map format:

- `control_plane_nodes_map`
- `worker_node_maps`

This is provider-agnostic: any infrastructure module (OpenStack, VMware, etc.) can be used as long as its outputs match the schema.

Example (one control-plane module and multiple worker modules):

```hcl
module "k8s_talos" {
  source = "../../modules/k8s-talos"

  cluster_name       = var.cluster_name
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  control_plane_nodes_map = module.control_plane.nodes
  worker_node_maps = [
    module.common_workers.nodes,
    module.gpu_workers.nodes,
    module.extra_workers.nodes,
  ]
}
```

If you need shared defaults for map-based inputs (for example `install_disk`, labels, taints, per-node patches), use:

- `control_plane_defaults`
- `worker_defaults`

## Rolling upgrade (sequential)

Recommended safe order for an HA Talos cluster:

1. Upgrade control-plane nodes one by one.
2. Upgrade worker nodes one by one.

Why: the control plane must preserve etcd quorum and API availability before moving compute nodes.

Practical Terraform flow:

- change image/version for a single VM in your infra module;
- run `apply` (optionally with `-target` for that VM);
- wait until the node is healthy/Ready;
- continue with the next node.

For staged config application use `apply_mode = "staged_if_needing_reboot"` (or `"staged"`).

For strict wave-based config rollout inside this module use:

- `rollout_control_plane_names = ["dc1-k8s-pi-m-01"]`
- `rollout_worker_names = ["dc1-k8s-pi-n-01"]`

These variables scope `talos_machine_configuration_apply` to specific nodes for the current apply.

Rollout filter semantics:

- `null` — apply to all nodes of the role;
- `[]` — apply to no nodes of the role;
- `["name-1", "name-2"]` — apply only to the listed nodes.

When upgrading Kubernetes via `kubernetes_version` in this module:

- apply control-plane changes first (one by one);
- then apply worker changes (one by one).
