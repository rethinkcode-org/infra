variable "hcloud_token" {}
variable "cloudflare_api_token" {}
variable "github_token" {}
variable "github_owner" {}
variable "core_repo" {}
variable "downstream_state_bucket" {}
variable "hcloud_server_location" {}
variable "environments" {
  type = map(
    object(
      {
        server_type      = string
        subdomain        = string
        domain           = string
        deploy_key_pub   = string
        instance_key_pub = string
      }
    )
  )
}
