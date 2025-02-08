//define resources here

resource "github_actions_secret" "aws_access_key_id" {
  repository = var.repository
  secret_name = "AWS_ACCESS_KEY_ID"
  plaintext_value = var.aws_access_key_id
}

resource "github_actions_secret" "aws_secret_access_key" {
  repository = var.repository
  secret_name = "AWS_SECRET_ACCESS_KEY"
  plaintext_value = var.aws_secret_access_key
}

resource "github_actions_secret" "aws_region" {
  repository = var.repository
  secret_name = "AWS_REGION"
  plaintext_value = var.aws_region
}

resource "github_actions_secret" "aws_ecr_repo_base_uri" {
  repository = var.repository
  secret_name = "AWS_ECR_LOGIN_URI"
  plaintext_value = var.aws_ecr_repo_base_uri
}
resource "github_actions_secret" "aws_ecr_repo_name" {
  repository = var.repository
  secret_name = "ECR_REPOSITORY_NAME"
  plaintext_value = var.aws_ecr_repo_name
}