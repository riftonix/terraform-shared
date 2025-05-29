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

resource "gitlab_group" "this" {
  name                    = var.name
  path                    = var.path
  description             = var.description
  avatar                  = var.avatar_path
  avatar_hash             = var.avatar_path != "" ? filesha256(var.avatar_path) : null
  visibility_level        = var.visibility_level
  parent_id               = var.parent_id
  project_creation_level  = var.project_creation_level
  request_access_enabled  = var.request_access_enabled
  subgroup_creation_level = var.subgroup_creation_level
}

resource "gitlab_group_access_token" "these" {
  for_each = var.group_access_tokens

  group        = gitlab_group.this.id
  name         = each.key
  expires_at   = each.value.expires_at
  access_level = each.value.access_level

  scopes = each.value.scopes
}

resource "gitlab_group_variable" "tokens" {
  for_each = var.group_access_tokens

  group       = gitlab_group.this.id
  key         = each.key
  value       = gitlab_group_access_token.these[each.key].token
  description = var.variables_description
}

resource "gitlab_group_variable" "these" {
  for_each = {
    for variable in local.variables_data : variable.internal_name => variable
  }

  group             = gitlab_group.this.id
  key               = each.value.var_key
  value             = each.value.var_value
  environment_scope = each.value.environment_scope
  masked            = each.value.masked
  protected         = each.value.protected
  variable_type     = each.value.variable_type
  description       = var.variables_description
}
