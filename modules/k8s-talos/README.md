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
| <a name="input_control_plane_nodes"></a> [control\_plane\_nodes](#input\_control\_plane\_nodes) | Existing Talos control-plane nodes. | <pre>list(object({<br/>    name         = string<br/>    node         = string<br/>    endpoint     = optional(string)<br/>    install_disk = optional(string)<br/>    labels       = optional(map(string), {})<br/>    taints = optional(list(object({<br/>      key    = string<br/>      value  = string<br/>      effect = string<br/>    })), [])<br/>    config_patches = optional(list(string), [])<br/>  }))</pre> | n/a | yes |
| <a name="input_kubeconfig_server_host"></a> [kubeconfig\_server\_host](#input\_kubeconfig\_server\_host) | Host to write into kubeconfig server URL. If null, cluster_endpoint_host is used. | `string` | `null` | no |
| <a name="input_kubernetes_version"></a> [kubernetes\_version](#input\_kubernetes\_version) | Kubernetes version embedded into Talos machine configuration. | `string` | n/a | yes |
| <a name="input_talos_version"></a> [talos\_version](#input\_talos\_version) | Talos version used for generated machine configuration features. | `string` | n/a | yes |
| <a name="input_talosconfig_endpoints"></a> [talosconfig\_endpoints](#input\_talosconfig\_endpoints) | Talos API endpoints list to be written into talosconfig. If empty, all control-plane endpoints are used. | `list(string)` | `[]` | no |
| <a name="input_worker_config_patches"></a> [worker\_config\_patches](#input\_worker\_config\_patches) | Extra config patches applied to all worker nodes. | `list(string)` | `[]` | no |
| <a name="input_worker_nodes"></a> [worker\_nodes](#input\_worker\_nodes) | Existing Talos worker nodes. | <pre>list(object({<br/>    name         = string<br/>    node         = string<br/>    endpoint     = optional(string)<br/>    install_disk = optional(string)<br/>    labels       = optional(map(string), {})<br/>    taints = optional(list(object({<br/>      key    = string<br/>      value  = string<br/>      effect = string<br/>    })), [])<br/>    config_patches = optional(list(string), [])<br/>  }))</pre> | `[]` | no |

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

## Как применять patches (аналогично terraform-hcloud-talos-main)

Патчи передаются как YAML-строки в переменные:

- `control_plane_config_patches` — общие патчи для всех control-plane
- `worker_config_patches` — общие патчи для всех worker
- `control_plane_nodes[*].config_patches` / `worker_nodes[*].config_patches` — патчи только для конкретной ноды

Пример:

```hcl
module "k8s_talos" {
  source = "../../"

  cluster_name       = var.cluster_name
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  cluster_endpoint_host = var.cluster_endpoint_host

  control_plane_nodes = var.control_plane_nodes
  worker_nodes        = var.worker_nodes

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

Готовый рабочий пример с patch-файлами добавлен в `examples/base`:

- `examples/base/main.tf`
- `examples/base/patches/registries.yaml`
- `examples/base/patches/kubelet/control-plane.yaml`
- `examples/base/patches/kubelet/worker.yaml`
