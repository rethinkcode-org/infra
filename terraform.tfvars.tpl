hcloud_token         = "dummy"
cloudflare_api_token = "dummy"
github_token         = "dummy"
github_owner         = "dummy"
core_repo            = "core"
downstream_state_bucket = "dummy"
hcloud_server_location  = "ngb1"
environments = {
  staging = {
    server_type        = "cx11"
    subdomain          = "staging"
    domain             = "example.com"
    deploy_key_pub     = "keys/staging/deploy/id.pub"
    instance_key_pub   = "keys/staging/instance/id.pub"
  }
  prod = {
    server_type        = "cx21"
    subdomain          = "@"
    domain             = "example.com"
    deploy_key_pub     = "keys/prod/deploy/id.pub"
    instance_key_pub   = "keys/prod/instance/id.pub"
  }
}
