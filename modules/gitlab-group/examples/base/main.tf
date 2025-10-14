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

module "riftonix_group_test" {
  source = "../../"

  name             = "riftonix-group-test"
  path             = "riftonix-group-test"
  visibility_level = "private"
}
