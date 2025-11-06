# Read dashboards
locals {
  dashboard_bodies = {
    for dashboard_body, _ in var.dashboards : jsondecode(dashboard_body).title => dashboard_body
  }
}

# Apply global jq expression
data "jq_query" "global" {
  for_each = local.dashboard_bodies
  query    = coalesce(var.global_jq_expression, ".")
  data     = each.value
}

# Apply individual jq expression
data "jq_query" "dashboard" {
  for_each = {
    for dashboard_body, jq_filter in var.dashboards : jsondecode(dashboard_body).title => jq_filter
  }
  query = coalesce(each.value, ".")
  data  = data.jq_query.global[each.key].result
}

# Create dashboard in grafana
resource "grafana_dashboard" "these" {
  for_each = local.dashboard_bodies

  folder    = var.folder_uid
  org_id    = var.org_id
  overwrite = var.overwrite

  config_json = data.jq_query.dashboard[each.key].result
}
