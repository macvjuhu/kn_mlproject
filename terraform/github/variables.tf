variable "github_token" {
  description = "The GitHub token with access to the repository"
  type        = string
}

variable "repository" {
  description = "The GitHub repository to set the secrets for"
  type        = string
}

variable "github_owner" {
  description = "The GitHub owner of the repository"
  type = string
}


variable "github_base_url" {
  description = "The base URL for the GitHub API"
  type    = string
  default = "https://api.github.com"
}

variable "aws_region" {
  description = "The AWS region to deploy to"
  type        = string
  default     = "us-east-1"
}

variable "aws_access_key_id" {
  description = "The AWS access key ID"
  type        = string
} 

variable "aws_secret_access_key" {
  description = "The AWS secret access key"
  type        = string
}

variable "aws_ecr_repo_base_uri" {
  description = "The base URI for the ECR repository"
  type        = string
}

variable "aws_ecr_repo_name" {
  description = "The name of the ECR repository"
  type        = string
} 