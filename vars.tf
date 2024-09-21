# Disk images
variable "image" {
  #source = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
  default = "/var/lib/libvirt/images/debian-12-genericcloud-amd64.qcow2"
  description = "Source of the Debian image"
}

# VM related vars
variable "number_of_sandboxes" {
  default = 2
  description = "The number of how many sandbox servers do we need"
}

variable "domain_name" {
  default = ".home.lab"
  description = "Domain name for the VMs"
}

variable "sandbox_subdomain" {
  default = "sandbox-"
  description = "Generic subdomain for sandbox VMs"
}

# Network related vars
variable "sandbox-network" {
  type = object({
    ipv4 = string
    gateway = string
    network = string
    netmask = string
    dns = string
  })
  default = {
    ipv4 = "192.168.150."
    gateway = "192.168.150.1"
    network = "192.168.150.0"
    netmask = "/24"
    dns = "192.168.150.1"
  }
  description = "Basic network settings for Sandbox VMs"
}

# Ansible related vars
variable "ansible_playbook_path" {
  default = "./ansible-playbooks"
  description = "path to ansible playbooks"
}