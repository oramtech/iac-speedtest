locals {
  cloudflare_zone_id = "us-east1-b"
}

resource "random_id" "speedtest_tunnel_secret" {
  byte_length = 35
}

resource "cloudflare_argo_tunnel" "speedtest" {
  account_id = var.cloudflare_account_id
  name       = "speedtest-tunnel"
  secret     = random_id.speedtest_tunnel_secret.b64_std
}

resource "cloudflare_tunnel_config" "speedtest" {
  account_id = var.cloudflare_account_id
  tunnel_id  = cloudflare_argo_tunnel.speedtest.id

  config {    
    ingress_rule {
      hostname = "speedtest.oram.tech"
      service  = "http://10.16.32.10:8765"
    }
    ingress_rule {
      service = "http_status:404"
    }
  }
}

resource "cloudflare_access_application" "speedtest" {
  account_id = var.cloudflare_account_id
  name             = "Speedtest"
  domain           = "speedtest.oram.tech"
  session_duration = "1h"
  type = "self_hosted"
}

resource "cloudflare_access_policy" "speedtest" {
  account_id = var.cloudflare_account_id
  application_id = cloudflare_access_application.speedtest.id
  name           = "Emails Policy"
  precedence     = "2"
  decision       = "allow"

  include {
    email = ["b@oram.co"]
  }
}

resource "cloudflare_record" "speedtest" {
  zone_id = var.cloudflare_dns_zone_id
  name    = "speedtest"
  value   = "${cloudflare_argo_tunnel.speedtest.id}.cfargotunnel.com"
  type    = "CNAME"
  proxied = true
}