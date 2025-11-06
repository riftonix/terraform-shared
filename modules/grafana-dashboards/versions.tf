terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = ">= 4.0.0"
    }
    jq = {
      source  = "massdriver-cloud/jq"
      version = ">= 0.2.1"
    }
  }
}
