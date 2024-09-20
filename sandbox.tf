resource "libvirt_volume" "sandbox-qcow2" {
  count = var.number_of_sandboxes
  name = "debian-12-sandbox-${count.index}.qcow2"
  pool = "default"
  source = var.image
  format = "qcow2"
}

data "template_file" "user_data-sandbox" {
  template = "${file("${path.module}/cloud_init.yml")}"
  count = var.number_of_sandboxes
  vars = {
    hostname   = "sandbox-${count.index}.home.lab"
    ip_address = "192.168.122.${count.index + 100}/24"
    gateway    = "192.168.122.1"
    dns        = "192.168.122.1"
  }
}

resource "libvirt_cloudinit_disk" "commoninit-sandbox" {
  count = var.number_of_sandboxes
  name = "commoninit-sandbox-${count.index}.iso"
  pool = "default"
  user_data = "${data.template_file.user_data-sandbox[count.index].rendered}"
}

resource "libvirt_domain" "sandbox" {
  count = var.number_of_sandboxes
  name = "${data.template_file.user_data-sandbox[count.index].vars.hostname}"
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

# wait until VMs become ready
# deletes old hostkey
# waits util ssh becomes ready
# adds new ssh hostkeys
resource "terraform_data" "sandbox-up" {
  count = var.number_of_sandboxes

  provisioner "local-exec" {
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${data.template_file.user_data-sandbox[count.index].vars.hostname}"
  }

  provisioner "local-exec" {
    command = "until nc -zv ${data.template_file.user_data-sandbox[count.index].vars.hostname} 22; do sleep 15; done"
  }

  provisioner "local-exec" {
    command = "ssh-keyscan -t rsa -H ${data.template_file.user_data-sandbox[count.index].vars.hostname} >> ~/.ssh/known_hosts"
  }
}

resource "terraform_data" "sandbox-ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory.yml --diff ${var.ansible_playbook_path}/sandbox-servers.yml"
  }

  depends_on = [ terraform_data.sandbox-up, ansible_group.sandbox, ansible_host.sandbox ]

}