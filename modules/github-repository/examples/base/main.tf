terraform {
  required_providers {
    github = {
      source  = "integrations/github"
      version = "6.6.0"
    }
  }
}

variable "github_token" {
  description = "Github token for terraform operations"
  type        = string
  sensitive   = true
}

provider "github" {
  token = var.github_token
}

module "github_repository_example" {
  source = "../../"

  name      = "example"
  auto_init = true
}
