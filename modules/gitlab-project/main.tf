locals {
  variables_data = flatten([
    for variable_key, variable in var.variables : [
      for env_index, env in lookup(variable, "environment_scopes", []) : {
        internal_name     = "${env}_${variable_key}"
        environment_scope = env
        var_key           = variable_key
        var_value         = lookup(variable, "values", null) != null ? variable.values[env_index] : null
        masked            = lookup(variable, "masked", false)
        protected         = lookup(variable, "protected", false)
        variable_type     = lookup(variable, "variable_type", "env_var")
      }
    ]
  ])
}

resource "gitlab_project" "this" {
  name                                  = var.project_name
  path                                  = var.project_name
  namespace_id                          = var.group_id
  default_branch                        = var.default_branch
  description                           = var.description
  initialize_with_readme                = var.initialize_with_readme
  only_allow_merge_if_pipeline_succeeds = var.only_allow_merge_if_pipeline_succeeds
  remove_source_branch_after_merge      = var.remove_source_branch_after_merge
  shared_runners_enabled                = var.shared_runners_enabled
  merge_method                          = var.merge_method
  pages_access_level                    = var.pages_access_level
  visibility_level                      = var.visibility_level
  archived                              = var.archived
  squash_option                         = var.squash_option
  build_timeout                         = var.build_timeout
  use_custom_template                   = var.template_project_id != null ? true : false
  template_project_id                   = var.template_project_id
  group_with_project_templates_id       = var.group_with_project_templates_id

  push_rules {
    commit_message_regex = var.commit_message_regex
  }
}

resource "gitlab_project_access_token" "these" {
  for_each = var.project_access_tokens

  project      = gitlab_project.this.id
  name         = each.key
  expires_at   = each.value.expires_at
  access_level = each.value.access_level

  scopes = each.value.scopes
}

resource "gitlab_pipeline_trigger" "these" {
  for_each = toset(var.project_trigger_tokens)

  description = each.value
  project     = gitlab_project.this.id
}

resource "gitlab_project_variable" "tokens" {
  for_each = var.project_access_tokens

  project     = gitlab_project.this.id
  key         = each.key
  value       = gitlab_project_access_token.these[each.key].token
  description = var.variables_description
}

resource "gitlab_project_environment" "these" {
  count = length(var.environments)

  name    = var.environments[count.index]
  project = gitlab_project.this.id
}

resource "gitlab_project_variable" "these" {
  for_each = {
    for variable in local.variables_data : variable.internal_name => variable
  }

  project           = gitlab_project.this.id
  key               = each.value.var_key
  value             = each.value.var_value
  environment_scope = each.value.environment_scope
  masked            = each.value.masked
  protected         = each.value.protected
  variable_type     = each.value.variable_type
  description       = var.variables_description
}

resource "gitlab_branch_protection" "these" {
  for_each = toset(var.protected_branches)

  project                = gitlab_project.this.id
  branch                 = each.key
  push_access_level      = "no one"
  allow_force_push       = false
  merge_access_level     = "developer"
  unprotect_access_level = "maintainer"
}

resource "gitlab_project_job_token_scopes" "this" {
  project            = gitlab_project.this.id
  target_project_ids = []
  target_group_ids   = var.allowed_group_ids
}

resource "gitlab_repository_file" "these" {
  for_each = var.files

  project        = gitlab_project.this.id
  file_path      = each.key
  content        = each.value
  branch         = var.default_branch
  commit_message = "chore: update data from terraform"
  encoding       = "text"
}
