variable "name" {
  description = "The name of the repository"
  type        = string
}

variable "description" {
  description = "Description of the repository"
  type        = string
  default     = null
}

variable "visibility" {
  description = "Repository visibility: public, private or internal"
  type        = string
  default     = "public"
}

variable "has_issues" {
  description = "Enable GitHub Issues"
  type        = bool
  default     = true
}

variable "has_wiki" {
  description = "Enable GitHub Wiki"
  type        = bool
  default     = true
}

variable "has_projects" {
  description = "Enable GitHub Projects"
  type        = bool
  default     = false
}

variable "is_template" {
  description = "Create repository as a template"
  type        = bool
  default     = false
}

variable "auto_init" {
  description = "Create an initial commit with empty README"
  type        = bool
  default     = false
}

variable "gitignore_template" {
  description = "Gitignore template to apply"
  type        = string
  default     = null
}

variable "license_template" {
  description = "License template to apply"
  type        = string
  default     = null
}

variable "allow_merge_commit" {
  description = "Allow merge commits"
  type        = bool
  default     = true
}

variable "allow_squash_merge" {
  description = "Allow squash merges"
  type        = bool
  default     = true
}

variable "allow_rebase_merge" {
  description = "Allow rebase merges"
  type        = bool
  default     = true
}

variable "allow_auto_merge" {
  description = "Allow auto-merge for pull requests"
  type        = bool
  default     = false
}

variable "topics" {
  description = "List of topics for the repository"
  type        = list(string)
  default     = []
}

variable "homepage_url" {
  description = "URL of homepage of the project"
  type        = string
  default     = null
}

variable "pages" {
  description = "GitHub Pages configuration"
  type = object({
    build_type = optional(string)
    cname      = optional(string)
    branch     = optional(string)
    path       = optional(string)
  })
  default = null
}

variable "security_and_analysis" {
  description = "Security and analysis configuration"
  type = object({
    advanced_security               = optional(object({ status = string })) # enabled or disabled
    secret_scanning                 = optional(object({ status = string }))
    secret_scanning_push_protection = optional(object({ status = string }))
  })
  default = null
}

variable "repository_default_branch" {
  description = "Repository default branch"
  type        = string
  default     = "master"
}

variable "template" {
  type = object({
    owner                = string
    repository           = string
    include_all_branches = optional(bool, false)
  })
  default = null
}

variable "protected_branches" {
  description = "Protected branches map: key is branch name or pattern, value is branch protection settings"
  type = map(object({
    enforce_admins                  = optional(bool, true)
    allows_deletions                = optional(bool, false)
    allows_force_pushes             = optional(bool, false)
    force_push_bypassers            = optional(set(string), [])
    lock_branch                     = optional(bool, false)
    require_conversation_resolution = optional(bool, false)
    require_signed_commits          = optional(bool, false)
    required_linear_history         = optional(bool, false)
    required_status_checks = optional(object({
      contexts = optional(set(string), [])
      strict   = optional(bool, true)
    }), null)
    required_pull_request_reviews = optional(object({
      dismiss_stale_reviews           = optional(bool, true)
      dismissal_restrictions          = optional(set(string), [])
      pull_request_bypassers          = optional(set(string), [])
      require_code_owner_reviews      = optional(bool, false)
      require_last_push_approval      = optional(bool, false)
      required_approving_review_count = optional(number, 1)
      restrict_dismissals             = optional(bool, false)
    }), null)
    restrict_pushes = optional(object({
      blocks_creations = optional(bool, false)
      push_allowances  = optional(set(string), [])
    }), null)
  }))
  default = {}
}
