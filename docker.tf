resource "docker_image" "cloudflared" {
  name = "cloudflare/cloudflared:latest"
}

resource "docker_container" "speedtest-cloudflared" {
  image = docker_image.cloudflared.image_id
  name  = "speedtest_cloudflared"
  restart = "always"
  command = ["tunnel", "--no-autoupdate", "run", "--token", "${cloudflare_argo_tunnel.speedtest.tunnel_token}"]
}

resource "docker_image" "speedtest" {
  name = "henrywhitaker3/speedtest-tracker:latest"
}

resource "docker_volume" "shared_volume" {
  name = "speedtest__config"
  driver = "local"
  driver_opts = {
    type = "nfs"
    o = "addr=10.16.32.10,rw,noatime,rsize=8192,wsize=8192,tcp,timeo=14"
    device = ":/volume1/docker/speedtest__config"
  }
}

resource "docker_container" "speedtest" {
  image = docker_image.speedtest.image_id
  name  = "speedtest"
  restart = "always"
  ports {
    internal = "80"
    external = "8765"
  }
  volumes {
    container_path = "/config"
    volume_name = "speedtest__config"
  }
  env = [
    "OOKLA_EULA_GDPR=true"
  ]
}

