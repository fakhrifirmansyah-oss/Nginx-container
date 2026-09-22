terraform {
  required_version = ">= 1.6.0"

  required_providers {
    docker = {
      source = "kreuzwerker/docker"
    }
  }
}
