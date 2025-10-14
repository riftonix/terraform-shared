data "kubectl_file_documents" "these" {
  content = var.manifest_content
}

resource "kubectl_manifest" "resources" {
  for_each  = data.kubectl_file_documents.these.manifests

  yaml_body          = each.value
  sensitive_fields   = var.sensitive_fields
  force_new          = var.force_new
  server_side_apply  = var.server_side_apply
  force_conflicts    = var.force_conflicts
  apply_only         = var.apply_only
  ignore_fields      = var.ignore_fields
  override_namespace = var.override_namespace
  validate_schema    = var.validate_schema
  wait               = var.wait
  wait_for_rollout   = var.wait_for_rollout
}