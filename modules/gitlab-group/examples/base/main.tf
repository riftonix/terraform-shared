terraform {
  required_providers {
    gitlab = {
      source  = "gitlabhq/gitlab"
      version = "18.4.1"
    }
  }
}

provider "gitlab" {
  token    = "glpat-gO69l8MpdO5HzHdHHJH-4286MQp1OmkwNWx4Cw.01.121mdiu0t"
  base_url = "https://gitlab.com/api/v4/"
}

module "riftonix_group_test" {
  source = "../../"

  name             = "riftonix-group-test"
  path             = "riftonix-group-test"
  visibility_level = "private"
}
