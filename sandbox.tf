resource "libvirt_volume" "sandbox-qcow2" {
  count = 2
  name = "debian-12-sandbox-${count.index}.qcow2"
  pool = "default"
  source = var.image
  format = "qcow2"
}

data "template_file" "user_data-sandbox" {
  template = "${file("${path.module}/cloud_init.yml")}"
  count = 2
  vars = {
    hostname   = "sandbox-${count.index}.home.lab"
    ip_address = "192.168.122.${count.index + 100}/24"
    gateway    = "192.168.122.1"
    dns        = "192.168.122.1"
  }
}

resource "libvirt_cloudinit_disk" "commoninit-sandbox" {
  count = 2
  name = "commoninit-sandbox-${count.index}.iso"
  pool = "default"
  user_data = "${data.template_file.user_data-sandbox[count.index].rendered}"
}

resource "libvirt_domain" "sandbox" {
  count = 2
  name = "sandbox-${count.index}"
  memory = 2048
  vcpu = 2

  cloudinit = "${libvirt_cloudinit_disk.commoninit-sandbox[count.index].id}"

  network_interface {
    network_name = "default"
  }

  disk {
    volume_id = "${libvirt_volume.sandbox-qcow2[count.index].id}"
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

resource "null_resource" "sandbox" {
  count = 2

  provisioner "local-exec" {
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${data.template_file.user_data-sandbox[count.index].vars.hostname}"
  }

  provisioner "local-exec" {
    command = "until nc -zv ${data.template_file.user_data-sandbox[count.index].vars.hostname} 22; do echo 'Waiting for ssh to be avaiable'; sleep 15; done"
  }

  provisioner "local-exec" {
    command = "ANSIBLE_HOST_KEY_CHECKING=False ansible-playbook -i ~/Documents/ansible/personal-ansible-inventory --diff --limit ${data.template_file.user_data-sandbox[count.index].vars.hostname} ~/Documents/ansible/personal-ansible/common.yml"
  }
}