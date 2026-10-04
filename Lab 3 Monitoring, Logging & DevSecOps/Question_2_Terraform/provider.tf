# ==============================================================================
# Terraform Provider Configuration
# Lab 3: Monitoring, Logging & DevSecOps - Task 2
# ==============================================================================

terraform {
  required_version = ">= 1.5.0"

  required_providers {
    docker = {
      source  = "kreuzwerker/docker"
      version = "~> 3.0.2"
    }
    local = {
      source  = "hashicorp/local"
      version = "~> 2.4.0"
    }
  }
}

# Configure the Docker Provider
# Automatically detects Docker daemon on Windows (named pipe) or Unix socket
provider "docker" {
  host = "npipe:////./pipe/docker_engine"
}
