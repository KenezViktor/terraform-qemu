resource "libvirt_volume" "sandbox-b-qcow2" {
  name = "debian-12-sandbox-b.qcow2"
  pool = "default"
  #source = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
  source = "/var/lib/libvirt/images/debian-12-genericcloud-amd64.qcow2"
  format = "qcow2"
}

data "template_file" "user_data-sandbox-b" {
  template = "${file("${path.module}/cloud_init.cfg")}"
  vars = {
    hostname   = "sandbox-b.home.lab"
    ip_address = "192.168.122.152/24"
    gateway    = "192.168.122.1"
    dns        = "192.168.122.1"
  }
}

resource "libvirt_cloudinit_disk" "commoninit-sandbox-b" {
  name = "commoninit-sandbox-b.iso"
  pool = "default"
  user_data = "${data.template_file.user_data-sandbox-b.rendered}"
}

resource "libvirt_domain" "sandbox-b" {
  name = "sandbox-b"
  memory = 2048
  vcpu = 2

  cloudinit = "${libvirt_cloudinit_disk.commoninit-sandbox-b.id}"

  network_interface {
    network_name = "default"
    mac = "00:50:56:a1:b1:c3"
  }

  disk {
    volume_id = "${libvirt_volume.sandbox-b-qcow2.id}"
  }

  console {
    type = "pty"
    target_type = "serial"
    target_port = 0
  }

  graphics {
    type = "spice"
    listen_address = "address"
    autoport = true
  }
}