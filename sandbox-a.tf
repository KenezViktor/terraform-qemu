resource "libvirt_volume" "sandbox-a-qcow2" {
  name = "debian-12-sandbox-a.qcow2"
  pool = "default"
  #source = "https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-genericcloud-amd64.qcow2"
  source = "/var/lib/libvirt/images/debian-12-genericcloud-amd64.qcow2"
  format = "qcow2"
}

data "template_file" "user_data-sandbox-a" {
  template = "${file("${path.module}/cloud_init.cfg")}"
  vars = {
    hostname   = "sandbox-a.home.lab"
    ip_address = "192.168.122.151/24"
    gateway    = "192.168.122.1"
    dns        = "192.168.122.1"
  }
}

resource "libvirt_cloudinit_disk" "commoninit-sandbox-a" {
  name = "commoninit-sandbox-a.iso"
  pool = "default"
  user_data = "${data.template_file.user_data-sandbox-a.rendered}"
}

resource "libvirt_domain" "sandbox-a" {
  name = "sandbox-a"
  memory = 2048
  vcpu = 2

  cloudinit = "${libvirt_cloudinit_disk.commoninit-sandbox-a.id}"

  network_interface {
    network_name = "default"
    mac = "00:50:56:a1:b1:c2"
  }

  disk {
    volume_id = "${libvirt_volume.sandbox-a-qcow2.id}"
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