### Usage
- Create creds in shared files mention in provider.tf
- Create secrets.env in this folder - 
```
#!/bin/zsh

export TF_VAR_github_runner_token="your-token"

```
- Source secrets.env in your terminal before executing terraform commands

### If creating your own envionment
Remove terraform.tfstate* if you are creating your own repo
