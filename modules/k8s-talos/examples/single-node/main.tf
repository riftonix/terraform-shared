terraform {
  required_providers {
    talos = {
      source  = "siderolabs/talos"
      version = ">= 0.9.0"
    }
  }
}

module "k8s_talos_single_node" {
  source = "../../"

  cluster_name       = var.cluster_name
  talos_version      = var.talos_version
  kubernetes_version = var.kubernetes_version

  cluster_endpoint_host = var.control_plane_node_ip

  control_plane_allow_schedule = true

  control_plane_nodes = [
    {
      name     = "cp-1"
      node     = var.control_plane_node_ip
      endpoint = var.control_plane_node_ip
    }
  ]
}

output "cluster_endpoint" {
  value = module.k8s_talos_single_node.cluster_endpoint
}

output "talosconfig" {
  value     = module.k8s_talos_single_node.talosconfig
  sensitive = true
}

output "kubeconfig" {
  value     = module.k8s_talos_single_node.kubeconfig
  sensitive = true
}
