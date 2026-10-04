# ==============================================================================
# DevOps Lab 3 - Task 2: Provision Scalable Infrastructure using Terraform
# ==============================================================================

# 1. Create a dedicated Docker bridge network for our application
resource "docker_network" "app_network" {
  name = "devops_lab_network"
}

# 2. Pull the Nginx Alpine image
resource "docker_image" "nginx" {
  name         = "nginx:alpine"
  keep_locally = true
}

# 3. Create backend web server instances (scalable via count)
resource "docker_container" "web" {
  count = var.instance_count
  name  = "web-server-${count.index + 1}"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.app_network.name
  }

  upload {
    file    = "/usr/share/nginx/html/index.html"
    content = "<html><body style='font-family:sans-serif;text-align:center;padding:50px;'><h1>Backend Web Server #${count.index + 1}</h1><p>Status: Healthy | Managed by Terraform</p></body></html>"
  }
}

# 4. Create an Nginx Load Balancer to distribute incoming traffic
resource "docker_container" "load_balancer" {
  name  = "nginx-load-balancer"
  image = docker_image.nginx.image_id

  networks_advanced {
    name = docker_network.app_network.name
  }

  ports {
    internal = 80
    external = var.app_port
  }

  # Generate Nginx upstream configuration dynamically from backend list
  upload {
    file = "/etc/nginx/nginx.conf"
    content = templatefile("${path.module}/templates/nginx.conf.tftpl", {
      backends = [
        for i in range(var.instance_count) : {
          name = "web-server-${i + 1}"
          port = 80
        }
      ]
    })
  }

  depends_on = [docker_container.web]
}
