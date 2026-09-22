variable "podman_socket" {
  type        = string
  description = "Path to Podman or Docker UNIX socket"
  default     = "unix:///run/user/1000/podman/podman.sock"
}

provider "docker" {
  host = var.podman_socket
}

resource "docker_image" "nginx" {
  name         = "docker.io/library/nginx:latest"
  keep_locally = true
}

resource "docker_container" "nginx" {
  image = docker_image.nginx.image_id
  name  = "nginx-tofu"

  ports {
    internal = 80
    external = 8082
  }

  volumes {
    host_path      = "${abspath(path.module)}/index.html"
    container_path = "/usr/share/nginx/html/index.html"
    read_only      = true
  }
}

output "container_name" {
  value       = docker_container.nginx.name
  description = "Nama container Nginx yang dideploy"
}

output "nginx_url" {
  value       = "http://localhost:8082"
  description = "URL untuk mengakses Nginx"
}
