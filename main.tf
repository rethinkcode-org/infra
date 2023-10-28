terraform {
  backend "s3" {}
  required_providers {
    cloudflare = {
      source = "cloudflare/cloudflare"
    }
    github = {
      source = "integrations/github"
    }
    hcloud = {
      source = "hetznercloud/hcloud"
    }
  }
}

provider "local" {}

provider "null" {}

provider "hcloud" {
  token = var.hcloud_token
}

provider "cloudflare" {
  api_token = var.cloudflare_api_token
}

provider "github" {
  token = var.github_token
  owner = var.github_owner
}

locals {
  env                = terraform.workspace
  env_vars           = lookup(var.environments, local.env, null)
  subdomain          = local.env_vars.subdomain
  domain             = local.env_vars.domain
  fqdn               = local.subdomain == "@" ? local.domain : "${local.subdomain}.${local.domain}"
  subdomain_wildcard = local.subdomain == "@" ? "*" : "*.${local.subdomain}"
  known_hosts_object = "${local.fqdn}/known_hosts"
}

data "cloudflare_zones" "zone" {
  filter {
    name   = local.domain
    status = "active"
    paused = false
  }
}

resource "hcloud_ssh_key" "ssh_key" {
  name       = "${local.env}-${local.domain}-ssh-key"
  public_key = file(local.env_vars.instance_key_pub)
}

resource "hcloud_firewall" "firewall" {
  name = "${local.env}-${local.domain}-firewall"
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "22"
    source_ips = ["0.0.0.0/0"]
  }
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "80"
    source_ips = ["0.0.0.0/0"]
  }
  rule {
    direction  = "in"
    protocol   = "tcp"
    port       = "443"
    source_ips = ["0.0.0.0/0"]
  }
}

resource "hcloud_server" "server" {
  name         = "${local.env}-${local.domain}-server"
  server_type  = local.env_vars.server_type
  image        = "ubuntu-22.04"
  ssh_keys     = [hcloud_ssh_key.ssh_key.id]
  firewall_ids = [hcloud_firewall.firewall.id]
  keep_disk    = true
  location     = var.hcloud_server_location
}

resource "null_resource" "known_hosts" {
  triggers = {
    server_id          = hcloud_server.server.id
    known_hosts_s3_url = "s3://${var.downstream_state_bucket}/${local.known_hosts_object}"
  }
  provisioner "local-exec" {
    command = <<EOT
      until nc -z -v -w5 ${hcloud_server.server.ipv4_address} 22; do
        echo "Waiting for SSH to become available..."
        sleep 5
      done
      echo "$(ssh-keyscan ${hcloud_server.server.ipv4_address})" > "/tmp/${local.env}.known_hosts"
      sed -i "s/${hcloud_server.server.ipv4_address}/${local.fqdn}/" "/tmp/${local.env}.known_hosts"
      aws s3 cp "/tmp/${local.env}.known_hosts" "${self.triggers.known_hosts_s3_url}"
    EOT
  }
  provisioner "local-exec" {
    when    = destroy
    command = "aws s3 rm ${self.triggers.known_hosts_s3_url}"
  }
}

resource "cloudflare_record" "record" {
  zone_id = data.cloudflare_zones.zone.zones[0].id
  name    = local.subdomain
  value   = hcloud_server.server.ipv4_address
  type    = "A"
  ttl     = 120
}

resource "cloudflare_record" "record_wildcard" {
  zone_id = data.cloudflare_zones.zone.zones[0].id
  name    = local.subdomain_wildcard
  value   = hcloud_server.server.ipv4_address
  type    = "A"
  ttl     = 120
}

resource "github_repository_deploy_key" "deploy_key" {
  title      = "${local.env}-${local.domain}-deploy-key"
  repository = var.core_repo
  key        = file(local.env_vars.deploy_key_pub)
  read_only  = "true"
}
