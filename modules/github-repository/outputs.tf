output "full_name" {
  description = "The full name of the repository (e.g. org/repo)"
  value       = github_repository.this.full_name
}

output "html_url" {
  description = "URL to the repository on GitHub"
  value       = github_repository.this.html_url
}

output "ssh_clone_url" {
  description = "SSH URL for cloning"
  value       = github_repository.this.ssh_clone_url
}

output "http_clone_url" {
  description = "HTTPS URL for cloning"
  value       = github_repository.this.http_clone_url
}
