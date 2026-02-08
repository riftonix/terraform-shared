variable "project_name" {
  description = "Gitlab project name"
  type        = string
}

variable "group_id" {
  description = "Gitlab group id"
  type        = number
}

variable "default_branch" {
  description = "Gitlab default branch in project, i.e. main"
  type        = string
  default     = "master"
}

variable "description" {
  description = "Gitlab project description"
  type        = string
  default     = ""
}

variable "avatar_path" {
  description = "Gitlab group avatar path"
  type        = string
  default     = ""
}

variable "initialize_with_readme" {
  description = "Is gitlab project will be with default readme or not"
  type        = bool
  default     = true
}

variable "archived" {
  description = "Is gitlab project archived or not"
  type        = bool
  default     = false
}

variable "only_allow_merge_if_pipeline_succeeds" {
  description = "Merge in default branch only if pipeline succeeds or not"
  type        = bool
  default     = true
}

variable "remove_source_branch_after_merge" {
  description = "Remove source branch after merge or not"
  type        = bool
  default     = true
}

variable "shared_runners_enabled" {
  description = "Enable shared gitlab runners or not"
  type        = bool
  default     = true
}

variable "merge_method" {
  description = "Merge method for gitlab project"
  type        = string
  default     = "ff"
}

variable "environments" {
  description = "Gitlab project environments, i.e. dev, prod, stage"
  type        = list(string)
  default     = []
}

variable "variables" {
  description = "Gitlab variables for project"
  # type = object({})
  default = {}
}

variable "pages_access_level" {
  description = "Gitlab project pages access level"
  type        = string
  default     = "private"
}

variable "visibility_level" {
  description = "Gitlab project visibility level"
  type        = string
  default     = "private"
}

variable "commit_message_regex" {
  description = "All commit messages must match this regex"
  type        = string
  default     = null
}

variable "project_access_tokens" {
  description = "Project access tokens"
  default     = {}
}

variable "project_trigger_tokens" {
  description = "Project trigger tokens"
  default     = []
}

variable "variables_description" {
  description = "Description for all gitlab variables"
  default     = "Managed by terraform"
}

variable "protected_branches" {
  description = "Protected branches map: key is branch name, value is branch protection settings"
  type = map(object({
    push_access_level            = optional(string, "no one")
    merge_access_level           = optional(string, "developer")
    unprotect_access_level       = optional(string, "maintainer")
    allow_force_push             = optional(bool, false)
    code_owner_approval_required = optional(bool, false)
    allowed_to_push = optional(list(object({
      user_id       = optional(number)
      group_id      = optional(number)
      deploy_key_id = optional(number)
    })), [])
    allowed_to_merge = optional(list(object({
      user_id  = optional(number)
      group_id = optional(number)
    })), [])
    allowed_to_unprotect = optional(list(object({
      user_id  = optional(number)
      group_id = optional(number)
    })), [])
  }))
  default = {}
}

variable "squash_option" {
  description = "Squash commits when merge request. Valid values are never, always, default_on, or default_off"
  type        = string
  default     = "never"
}

variable "allowed_group_ids" {
  description = "Allowed groups to trigger pipelines"
  type        = list(any)
  default     = []
}

variable "allowed_project_ids" {
  description = "Allowed projects to trigger pipelines"
  type        = list(any)
  default     = []
}

variable "build_timeout" {
  description = "Gitlab job timeout"
  type        = number
  default     = 3600
}

variable "template_project_id" {
  description = "Project ID of the custom template to use when creating the project"
  type        = number
  default     = null
}

variable "group_with_project_templates_id" {
  description = "Group ID with templates"
  type        = number
  default     = null
}

variable "files" {
  description = "Map of files to create in repo"
  type        = map(string)
  default     = {}
}

