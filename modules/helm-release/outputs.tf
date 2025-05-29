output "release_name" {
  description = "Helm release name"
  value       = helm_release.this.name
}

output "release_status" {
  description = "Status of the Helm release"
  value       = helm_release.this.status
}

output "manifest" {
  description = "Rendered manifest of installed resources"
  value       = helm_release.this.manifest
}

output "release_version" {
  description = "Deployed chart version"
  value       = helm_release.this.version
}
