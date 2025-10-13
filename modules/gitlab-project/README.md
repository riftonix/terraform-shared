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
| [gitlab_pipeline_trigger.these](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/pipeline_trigger) | resource |
| [gitlab_project.this](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project) | resource |
| [gitlab_project_access_token.these](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_access_token) | resource |
| [gitlab_project_environment.these](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_environment) | resource |
| [gitlab_project_variable.these](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |
| [gitlab_project_variable.tokens](https://registry.terraform.io/providers/gitlabhq/gitlab/latest/docs/resources/project_variable) | resource |

## Inputs

| Name | Description | Type | Default | Required |
|------|-------------|------|---------|:--------:|
| <a name="input_commit_message_regex"></a> [commit\_message\_regex](#input\_commit\_message\_regex) | All commit messages must match this regex | `string` | `null` | no |
| <a name="input_default_branch"></a> [default\_branch](#input\_default\_branch) | Gitlab default branch in project, i.e. main | `string` | `"main"` | no |
| <a name="input_description"></a> [description](#input\_description) | Gitlab project description | `string` | `""` | no |
| <a name="input_environments"></a> [environments](#input\_environments) | Gitlab project environments, i.e. dev, prod, stage | `list(string)` | `[]` | no |
| <a name="input_group_id"></a> [group\_id](#input\_group\_id) | Gitlab group id | `number` | n/a | yes |
| <a name="input_initialize_with_readme"></a> [initialize\_with\_readme](#input\_initialize\_with\_readme) | Is gitlab project will be with default readme or not | `bool` | `true` | no |
| <a name="input_merge_method"></a> [merge\_method](#input\_merge\_method) | Merge method for gitlab project | `string` | `"ff"` | no |
| <a name="input_only_allow_merge_if_pipeline_succeeds"></a> [only\_allow\_merge\_if\_pipeline\_succeeds](#input\_only\_allow\_merge\_if\_pipeline\_succeeds) | Merge in default branch only if pipeline succeeds or not | `bool` | `true` | no |
| <a name="input_pages_access_level"></a> [pages\_access\_level](#input\_pages\_access\_level) | Gitlab project pages access level | `string` | `"private"` | no |
| <a name="input_project_access_tokens"></a> [project\_access\_tokens](#input\_project\_access\_tokens) | Project access tokens | `map` | `{}` | no |
| <a name="input_project_name"></a> [project\_name](#input\_project\_name) | Gitlab project name | `string` | n/a | yes |
| <a name="input_project_trigger_tokens"></a> [project\_trigger\_tokens](#input\_project\_trigger\_tokens) | Project trigger tokens | `list` | `[]` | no |
| <a name="input_remove_source_branch_after_merge"></a> [remove\_source\_branch\_after\_merge](#input\_remove\_source\_branch\_after\_merge) | Remove source branch after merge or not | `bool` | `true` | no |
| <a name="input_shared_runners_enabled"></a> [shared\_runners\_enabled](#input\_shared\_runners\_enabled) | Enable shared gitlab runners or not | `bool` | `true` | no |
| <a name="input_variables"></a> [variables](#input\_variables) | Gitlab variables for project | `map` | `{}` | no |
| <a name="input_variables_description"></a> [variables\_description](#input\_variables\_description) | Description for all gitlab variables | `string` | `"Managed by terraform"` | no |
| <a name="input_visibility_level"></a> [visibility\_level](#input\_visibility\_level) | Gitlab project visibility level | `string` | `"private"` | no |

## Outputs

| Name | Description |
|------|-------------|
| <a name="output_access_tokens_data"></a> [access\_tokens\_data](#output\_access\_tokens\_data) | Projects tokens info |
| <a name="output_project_id"></a> [project\_id](#output\_project\_id) | Gitlab project id |
| <a name="output_trigger_tokens_data"></a> [trigger\_tokens\_data](#output\_trigger\_tokens\_data) | Projects tokens info |
<!-- END_TF_DOCS -->
