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

module "riftonix_project_test" {
  source = "../../"

  for_each = toset(["ms-1", "ms-2", "ms-3", "ms-4"])

  project_name                          = each.value
  group_id                              = 0
  only_allow_merge_if_pipeline_succeeds = true
  protected_branches                    = ["main", "master", "release/*"]
}
