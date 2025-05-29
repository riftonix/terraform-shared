<!-- BEGIN_TF_DOCS -->
## Requirements

| Name | Version |
|------|---------|
| <a name="requirement_gitlab"></a> [gitlab](#requirement\_gitlab) | >= 17.2.0 |

## Providers

| Name | Version |
|------|---------|
| <a name="provider_gitlab"></a> [gitlab](#provider\_gitlab) | >= 17.2.0 |

## Modules

No modules.

## Resources

| Name | Type |
|------|------|
| [gitlab_group.this](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/group) | resource |
| [gitlab_group_access_token.these](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/group_access_token) | resource |
| [gitlab_group_variable.these](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/group_variable) | resource |
| [gitlab_group_variable.tokens](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/group_variable) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_avatar_path"></a> [avatar\_path](#input\_avatar\_path) | Gitlab group avatar path | `string` | `""` | no |
| <a name="input_commit_message_regex"></a> [commit\_message\_regex](#input\_commit\_message\_regex) | All commit messages must match this regex | `string` | `null` | no |
| <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch) | Gitlab default branch in project, i.e. main | `string` | `"main"` | no |
| <a name="input_description"></a> [description](#input\_description) | Gitlab group description | `string` | `""` | no |
| <a name="input_group_access_tokens"></a> [group\_access\_tokens](#input\_group\_access\_tokens) | Group tokens | `map` | `{}` | no |
| <a name="input_initialize_with_readme"></a> [initialize\_with\_readme](#input\_initialize\_with\_readme) | Is gitlab project will be with default readme or not | `bool` | `true` | no |
| <a name="input_merge_method"></a> [merge\_method](#input\_merge\_method) | Merge method for gitlab project | `string` | `"ff"` | no |
| <a name="input_name"></a> [name](#input\_name) | Gitlab project name | `string` | n/a | yes |
| <a name="input_only_allow_merge_if_pipeline_succeeds"></a> [only\_allow\_merge\_if\_pipeline\_succeeds](#input\_only\_allow\_merge\_if\_pipeline\_succeeds) | Merge in default branch only if pipeline succeeds or not | `bool` | `true` | no |
| <a name="input_pages_access_level"></a> [pages\_access\_level](#input\_pages\_access\_level) | Gitlab project pages access level | `string` | `"private"` | no |
| <a name="input_parent_id"></a> [parent\_id](#input\_parent\_id) | Parent group id | `number` | `0` | no |
| <a name="input_path"></a> [path](#input\_path) | Gitlab group full path | `string` | n/a | yes |
| <a name="input_project_creation_level"></a> [project\_creation\_level](#input\_project\_creation\_level) | Permissions to create projects in the group. Valid values are: noone, maintainer, developer | `string` | `"maintainer"` | no |
| <a name="input_remove_source_branch_after_merge"></a> [remove\_source\_branch\_after\_merge](#input\_remove\_source\_branch\_after\_merge) | Remove source branch after merge or not | `bool` | `true` | no |
| <a name="input_request_access_enabled"></a> [request\_access\_enabled](#input\_request\_access\_enabled) | Allow users to request member access | `bool` | `true` | no |
| <a name="input_shared_runners_enabled"></a> [shared\_runners\_enabled](#input\_shared\_runners\_enabled) | Enable shared gitlab runners or not | `bool` | `true` | no |
| <a name="input_subgroup_creation_level"></a> [subgroup\_creation\_level](#input\_subgroup\_creation\_level) | Permissions to create subgroups. Valid values are: owner, maintainer | `string` | `"owner"` | no |
| <a name="input_variables"></a> [variables](#input\_variables) | Gitlab variables for project | `map` | `{}` | no |
| <a name="input_variables_description"></a> [variables\_description](#input\_variables\_description) | Description for all gitlab variables | `string` | `"Managed by terraform"` | no |
| <a name="input_visibility_level"></a> [visibility\_level](#input\_visibility\_level) | Gitlab group visibility level | `string` | `"internal"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_tokens_data"></a> [access\_tokens\_data](#output\_access\_tokens\_data) | Group tokens info |
| <a name="output_group_full_path"></a> [group\_full\_path](#output\_group\_full\_path) | Group full path |
| <a name="output_group_id"></a> [group\_id](#output\_group\_id) | Gitlab group id |
<!-- END_TF_DOCS -->