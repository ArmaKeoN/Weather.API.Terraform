terraform {
  required_providers {
    linode = {
      source  = "linode/linode"
      version = "1.29.4"
    }
  }
}

# Configure the Linode Provider
provider "linode" {
  token = var.token
}

# Create a Linode
resource "linode_instance" "weatherApiInstance" {
  label     = "weatherApi_instance"
  image     = "linode/centos7"
  region    = "us-central"
  type      = "g6-nanode-1"
  root_pass = var.root_pass
  provisioner "file" {
    source      = "setup_script.sh"
    destination = "/tmp/setup_script.sh"
    connection {
      type     = "ssh"
      host     = self.ip_address
      user     = "root"
      password = var.root_pass
    }
  }
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/setup_script.sh",
      "/tmp/setup_script.sh",
      "sleep 1"
    ]
    connection {
      type     = "ssh"
      host     = self.ip_address
      user     = "root"
      password = var.root_pass
    }
  }
}

# Create a Domain
#resource "linode_domain" "weatherApiDomain" {
#  domain    = "weatherApi_domain.com"
#  soa_email = "jonah.lozano03@gmail.com"
#  type      = "master"
#}

# Create a Domain Record
#resource "linode_domain_record" "weatherApiDomainRecord" {
#  domain_id   = linode_domain.weatherApiDomain.id
#  name        = "weatherApi_domain.com"
#  record_type = "A"
#  target      = linode_instance.weatherApiInstance.ip_address
#  ttl_sec     = 300
#}

# Create a Firewall
resource "linode_firewall" "weatherApiFirewall" {
  label = "weatherApi_firewall"
  inbound {
    label    = "allow-http"
    action   = "ACCEPT"
    protocol = "TCP"
    ports    = "22, 80, 8000, 8080"
    ipv4     = ["0.0.0.0/0"]
    ipv6     = ["ff00::/8"]
  }
  inbound_policy  = "DROP"
  outbound_policy = "ACCEPT"
  linodes         = [linode_instance.weatherApiInstance.id]
}

# Create variables

variable "token" {}
variable "root_pass" {}
