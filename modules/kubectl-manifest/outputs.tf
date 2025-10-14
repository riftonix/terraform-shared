output "resources_info" {
  description = "List of applied kubectl resources"
  value = [
    for r in kubectl_manifest.resources :
    {
      kind      = r.kind
      name      = r.name
      namespace = r.namespace
    }
  ]
}
