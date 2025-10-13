terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "18.4.1"
    }
  }
}

provider "gitlab" {
  token    = "<YOUR_GITLAB_TOKEN>"
  base_url = "https://gitlab.com/api/v4/"
}

data "gitlab_group" "riftonix" {
  full_path = "riftonix"
}

module "riftonix_project_test" {
  source = "../../"

  project_name                          = "riftonix_project_test"
  group_id                              = data.gitlab_group.riftonix.group_id
  only_allow_merge_if_pipeline_succeeds = false
  visibility_level                      = "internal"
  pages_access_level                    = "enabled"
  protected_branches                    = ["main", "master", "release/*"]
}
