output "group_id" {
  description = "Gitlab group id"
  value       = gitlab_group.this.id
}

output "group_full_path" {
  description = "Group full path"
  value       = gitlab_group.this.full_path
}

output "access_tokens_data" {
  description = "Group tokens info"
  value       = gitlab_group_access_token.these
}
