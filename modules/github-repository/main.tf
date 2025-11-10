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

  auto_init          = var.template == null ? var.auto_init : null
  gitignore_template = var.template == null ? var.gitignore_template : null
  license_template   = var.template == null ? var.license_template : null

  homepage_url = var.homepage_url

  topics = var.topics

  dynamic "template" {
    for_each = var.template != null ? [var.template] : []
    content {
      owner                = template.value.owner
      repository           = template.value.repository
      include_all_branches = template.value.include_all_branches
    }
  }

  dynamic "pages" {
    for_each = var.pages == null ? [] : [var.pages]
    content {
      build_type = try(pages.value.build_type, null)
      cname      = try(pages.value.cname, null)
      source {
        branch = try(pages.value.branch, null)
        path   = try(pages.value.path, null)
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

resource "github_branch_default" "this" {
  repository = github_repository.this.name
  branch     = github_branch.default.branch
}
