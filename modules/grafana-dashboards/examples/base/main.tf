terraform {
  required_providers {
    grafana = {
      source  = "grafana/grafana"
      version = "4.10.0"
    }
  }
}

provider "grafana" {
  url  = "https://grafana.example.com"
  auth = "test:test"
  insecure_skip_verify = true
}

module "kafka_dashboards" {
  source = "../../"
  folder_uid = "cesbbhbyyuhvka"
  dashboards = [
    {
      body = jsondecode(file("dashboards/strimzi-cruise-control.json"))
    }
  ]
}
