data "http" "ripe_announced_prefixes" {
  for_each = toset(var.resources)

  url = "${var.base_url}?resource=${each.value}"

  request_headers = {
    Accept = "application/json"
  }
}

locals {
  ipv4_prefixes = sort(distinct(flatten([
    for resource, response in data.http.ripe_announced_prefixes : [
      for prefix in try(jsondecode(response.response_body).data.prefixes, []) : prefix.prefix
      if length(regexall(":", prefix.prefix)) == 0
    ]
  ])))
}
