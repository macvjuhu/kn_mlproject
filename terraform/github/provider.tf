terraform {
  required_providers {
    github = {
      source  = "integrations/github"

    }
  }
}

provider "github" {
  token        = var.github_token
  owner        = var.github_owner
  #base_url     = var.github_base_url
}

