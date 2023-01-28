terraform {
  required_providers {
    digitalocean = {
      source  = "digitalocean/digitalocean"
      version = "~> 2.0"
    }
  }
}

# Configure the DigitalOcean Provider
provider "digitalocean" {
  token = var.do_token
}

# Create VM Jenkins
resource "digitalocean_droplet" "jenkins" {
  image    = "ubuntu-22-04-x64"
  name     = "jenkins"
  region   = var.region
  size     = "s-2vcpu-2gb"
  ssh_keys = [data.digitalocean_ssh_key.jornada.id]
}

data "digitalocean_ssh_key" "ssh_key_name" {
  name = var.ssh_key_name
}


# Create cluster
resource "digitalocean_kubernetes_cluster" "k8s" {
  name   = "k8s"
  region = var.region
  # Grab the latest version slug from `doctl kubernetes options versions`
  version = "1.24.4-do.1"

  node_pool {
    name       = "default"
    size       = "s-2vcpu-2gb"
    node_count = 2
  }
}

variable "do_token" {
  default = ""
}

variable "region" {
  default = "nyc1"
}

variable "ssh_key_name" {
  default = ""
}

output "jenkins_ip" {
  value = digitalocean_droplet.jenkins.ipv4_address
}

resource "local_file" "name" {
  content  = "kube_config.yaml"
  filename = digitalocean_kubernetes_cluster.k8s.kube_config.0
}
