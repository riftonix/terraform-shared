output "project_id" {
  description = "Gitlab project id"
  value       = gitlab_project.this.id
}

output "project_full_path" {
  description = "Gitlab project full path"
  value       = gitlab_project.this.path_with_namespace
}

output "access_tokens_data" {
  description = "Projects tokens info"
  value       = gitlab_project_access_token.these
}

output "trigger_tokens_data" {
  description = "Projects tokens info"
  value       = gitlab_pipeline_trigger.these
}
