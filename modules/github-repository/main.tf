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
  allow_auto_merge   = var.allow_auto_merge

  delete_branch_on_merge = var.delete_branch_on_merge

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

resource "github_branch_protection" "these" {
  for_each = var.protected_branches

  repository_id                   = github_repository.this.name
  pattern                         = each.key
  enforce_admins                  = each.value.enforce_admins
  allows_deletions                = each.value.allows_deletions
  allows_force_pushes             = each.value.allows_force_pushes
  force_push_bypassers            = each.value.force_push_bypassers
  lock_branch                     = each.value.lock_branch
  require_conversation_resolution = each.value.require_conversation_resolution
  require_signed_commits          = each.value.require_signed_commits
  required_linear_history         = each.value.required_linear_history

  dynamic "required_status_checks" {
    for_each = each.value.required_status_checks == null ? [] : [each.value.required_status_checks]
    content {
      contexts = required_status_checks.value.contexts
      strict   = required_status_checks.value.strict
    }
  }

  dynamic "required_pull_request_reviews" {
    for_each = each.value.required_pull_request_reviews == null ? [] : [each.value.required_pull_request_reviews]
    content {
      dismiss_stale_reviews           = required_pull_request_reviews.value.dismiss_stale_reviews
      dismissal_restrictions          = required_pull_request_reviews.value.dismissal_restrictions
      pull_request_bypassers          = required_pull_request_reviews.value.pull_request_bypassers
      require_code_owner_reviews      = required_pull_request_reviews.value.require_code_owner_reviews
      require_last_push_approval      = required_pull_request_reviews.value.require_last_push_approval
      required_approving_review_count = required_pull_request_reviews.value.required_approving_review_count
      restrict_dismissals             = required_pull_request_reviews.value.restrict_dismissals
    }
  }

  dynamic "restrict_pushes" {
    for_each = each.value.restrict_pushes == null ? [] : [each.value.restrict_pushes]
    content {
      blocks_creations = restrict_pushes.value.blocks_creations
      push_allowances  = restrict_pushes.value.push_allowances
    }
  }

  depends_on = [
    github_branch_default.this,
  ]
}
