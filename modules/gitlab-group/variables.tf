variable "name" {
  description = "Gitlab project name"
  type        = string
}

variable "path" {
  description = "Gitlab group full path"
  type        = string
}

variable "description" {
  description = "Gitlab group description"
  type        = string
  default     = ""
}

variable "avatar_path" {
  description = "Gitlab group avatar path"
  type        = string
  default     = ""
}

variable "visibility_level" {
  description = "Gitlab group visibility level"
  type        = string
  default     = "internal"
}

variable "parent_id" {
  description = "Parent group id"
  type        = number
  default     = 0
}

variable "project_creation_level" {
  description = "Permissions to create projects in the group. Valid values are: noone, maintainer, developer"
  type        = string
  default     = "maintainer"
}

variable "request_access_enabled" {
  description = "Allow users to request member access"
  type        = bool
  default     = true
}

variable "subgroup_creation_level" {
  description = "Permissions to create subgroups. Valid values are: owner, maintainer"
  type        = string
  default     = "owner"
}

variable "default_branch" {
  description = "Gitlab default branch in project, i.e. main"
  type        = string
  default     = "main"
}

variable "initialize_with_readme" {
  description = "Is gitlab project will be with default readme or not"
  type        = bool
  default     = true
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

variable "commit_message_regex" {
  description = "All commit messages must match this regex"
  type        = string
  default     = null
}

variable "group_access_tokens" {
  description = "Group tokens"
  default     = {}
}

variable "variables_description" {
  description = "Description for all gitlab variables"
  default     = "Managed by terraform"
}
