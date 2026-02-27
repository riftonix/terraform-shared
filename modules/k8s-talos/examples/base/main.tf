terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.9.0"
    }
  }
}

module "k8s_talos" {
  source = "../../"

  cluster_name       = var.cluster_name
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  # Kubernetes API endpoint that will be embedded into generated configs.
  cluster_endpoint_host = var.cluster_endpoint_host

  # Existing Talos nodes (VMs are NOT created by this module).
  control_plane_nodes = var.control_plane_nodes
  worker_nodes        = var.worker_nodes

  # Same idea as in terraform-hcloud-talos-main: common per-role patches.
  control_plane_config_patches = [
    file("${path.module}/patches/kubelet/control-plane.yaml"),
    file("${path.module}/patches/registries.yaml"),
  ]

  worker_config_patches = [
    file("${path.module}/patches/kubelet/worker.yaml"),
    file("${path.module}/patches/registries.yaml"),
  ]

  # Optional: rewrite kubeconfig server host for external access.
  kubeconfig_server_host = var.kubeconfig_server_host
}

output "cluster_endpoint" {
  value = module.k8s_talos.cluster_endpoint
}

output "talosconfig" {
  value     = module.k8s_talos.talosconfig
  sensitive = true
}

output "kubeconfig" {
  value     = module.k8s_talos.kubeconfig
  sensitive = true
}
