terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "4.10.0"
    }
    jq = {
      source  = "massdriver-cloud/jq"
      version = "0.2.1"
    }
  }
}

variable "grafana_url" {
  description = "Grafana scheme+host url"
  type        = string
  default     = "https://grafana.com"
}

variable "grafana_auth_string" {
  description = "Grafana auth string"
  type        = string
  sensitive   = true
}

variable "grafana_org_id" {
  description = "Grafana auth string"
  type        = number
  default     = 1
}

provider "grafana" {
  url                  = var.grafana_url
  auth                 = var.grafana_auth_string
  insecure_skip_verify = false # set true to ingnore untrusted tls certs
  org_id               = var.grafana_org_id
}

module "kubernetes_dashboards" {
  source               = "../../"
  folder_uid           = "0"
  global_jq_expression = <<-EOT
    ${file("overlay/utils.jq")}
    ${file("overlay/variables.jq")}
    ${file("overlay/panels.jq")}
    add_data_to_array_by_key(["templating", "list"]; k8s_cluster_var; "name") | patch_cluster_to_k8s_cluster
  EOT
  dashboards = {
    file("dashboards/api-server.json")                = "."
    file("dashboards/compute-resources-cluster.json") = "."
  }
}
