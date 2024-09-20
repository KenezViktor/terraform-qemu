variable "image" {
  #source = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
  default = "/var/lib/libvirt/images/debian-12-genericcloud-amd64.qcow2"
  description = "Source of the Debian image"
}

variable "number_of_sandboxes" {
  default = 2
  description = "The number of how many sandbox servers do we need"
}

variable "ansible_playbook_path" {
  default = "./ansible-playbooks"
  description = "path to ansible playbooks"
}