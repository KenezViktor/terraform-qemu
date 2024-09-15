variable "image" {
  #source = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
  default = "/var/lib/libvirt/images/debian-12-genericcloud-amd64.qcow2"
  description = "Source of the Debian image"
}