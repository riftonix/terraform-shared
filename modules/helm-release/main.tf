resource "helm_release" "this" {
  name             = var.release_name
  namespace        = var.namespace
  chart            = var.chart
  repository       = var.repository
  version          = var.chart_version
  create_namespace = var.create_namespace

  wait     = var.wait
  timeout  = var.timeout
  atomic   = var.atomic

  set = [
    for s in var.set : {
      name  = s.name
      value = s.value
      type  = lookup(s, "type", null)
    }
  ]

  values = var.values
}
