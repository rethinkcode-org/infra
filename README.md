# Core

## Architecture

## Using this repo
- Dependencies:
  - Setup Hetzner API keys
  - Install Terraform
  - Setup Github CLI (or otherwise get Github API token)
  - Setup Cloudflare and add a domain as zone (get Cloudflare API token)
- Clone repo (potentially some permissions are required if not public, and potentially you would want to fork it first, and clone your fork)
- If setting up for the first time, generate key pairs (else get existing keys securely):
  - `mkdir -p keys/staging/deploy keys/staging/instance keys/prod/deploy keys/prod/instance`
  - `ssh-keygen -t ed25519 -C "deankayton@gmail.com" -f keys/staging/instance/id`
  - `ssh-keygen -t ed25519 -C "deankayton@gmail.com" -f keys/staging/deploy/id`
  - `ssh-keygen -t ed25519 -C "deankayton@gmail.com" -f keys/prod/instance/id`
  - `ssh-keygen -t ed25519 -C "deankayton@gmail.com" -f keys/prod/deploy/id`
- `cp terraform.tfvars.tpl terraform.tfvars` and modify what is applicable (mainly Cloudflare and Github token)
- Provision Infrastructure (`terraform init` and `terraform apply` from root of repo)
- Change workspace to 'prod' `terraform workspace new prod` and `terraform workspace select prod` and repeat last step
- Staging is the default, so to go back, `terraform workspace select default`
- It is possible to use Ansible to provision staging and prod simultaneously
