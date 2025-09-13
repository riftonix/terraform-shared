terraform {
  required_providers {
    helm = {
      source  = "hashicorp/helm"
      version = "3.0.1"
    }
  }
}

provider "helm" {
  kubernetes = {
    config_path = "~/.kube/config"
  }
}

module "my_app" {
  source = "../../"

  release_name     = "my-app-release"
  namespace        = "my-namespace"
  chart            = "nginx"
  repository       = "oci://registry-1.docker.io/bitnamicharts"
  chart_version    = "20.0.2"
  create_namespace = true
  wait             = true
  timeout          = 600

  set = [
    {
      name  = "service.type"
      value = "LoadBalancer"
      type  = "string"
    },
    {
      name  = "replicaCount"
      value = "2"
    }
  ]
}
