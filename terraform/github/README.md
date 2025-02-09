### Usage
- Create creds in shared files mention in provider.tf
- Create secrets.env in this folder - 
```
#!/bin/zsh

export TF_VAR_aws_access_key_id = "your-aws-access-key"
export TF_VAR_aws_secret_access_key = "your-aws-secret"
export TF_VAR_github_token = "your-github-token"

```
- Source secrets.env in your terminal before executing terraform commands

### If creating your own envionment
Remove terraform.tfstate* if you are creating your own repo