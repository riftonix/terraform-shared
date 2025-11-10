terraform {
  required_providers {
    kubectl = {
      source  = "gavinbunney/kubectl"
      version = "1.19.0"
    }
  }
}

provider "kubectl" {
  load_config_file = true
  config_path      = "~/.kube/config"
}

module "k8s_apply" {
  source = "../../"

  manifest_content = file("rbac.yaml")
}
