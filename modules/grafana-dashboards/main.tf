resource "grafana_dashboard" "these" {
  for_each = {
    for dashboard in var.dashboards : dashboard.body.title => dashboard
  }

  folder = var.folder_uid
  org_id = var.org_id

  config_json = jsonencode(
    merge(
      each.value.body,
      {
        uid   = try(each.value.uid, null)
      }
    )
  )
  overwrite = var.overwrite
}
