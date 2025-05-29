resource "github_repository" "this" {
  name        = var.name
  description = var.description
  visibility  = var.visibility

  has_issues   = var.has_issues
  has_wiki     = var.has_wiki
  has_projects = var.has_projects

  is_template        = var.is_template
  allow_merge_commit = var.allow_merge_commit
  allow_squash_merge = var.allow_squash_merge
  allow_rebase_merge = var.allow_rebase_merge

  auto_init          = var.auto_init
  gitignore_template = var.gitignore_template
  license_template   = var.license_template

  homepage_url = var.homepage_url

  topics = var.topics

  dynamic "pages" {
    for_each = var.pages == null ? [] : [var.pages]
    content {
      source {
        branch = pages.value.branch
        path   = pages.value.path
      }
    }
  }

  dynamic "security_and_analysis" {
    for_each = var.security_and_analysis == null ? [] : [var.security_and_analysis]
    content {
      advanced_security {
        status = lookup(security_and_analysis.value.advanced_security, "status", null)
      }
      secret_scanning {
        status = lookup(security_and_analysis.value.secret_scanning, "status", null)
      }
      secret_scanning_push_protection {
        status = lookup(security_and_analysis.value.secret_scanning_push_protection, "status", null)
      }
    }
  }
}

resource "github_branch" "default" {
  repository = github_repository.this.name
  branch     = var.repository_default_branch
}

resource "github_branch_default" "this"{
  repository = github_repository.this.name
  branch     = github_branch.default.branch
}
