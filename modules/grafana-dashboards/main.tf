resource "grafana_dashboard" "these" {
  for_each = {
    for dashboard in var.dashboards: jsondecode(dashboard.body).title => dashboard
  }

  folder = var.folder_uid
  org_id = var.org_id

  config_json = jsonencode(
    merge(
      jsondecode(each.value.body),
      {
        uid     = try(each.value.uid, null)
        title   = each.value.title != null ? each.value.title : each.key
      }
    )
  )
  overwrite = var.overwrite
}
