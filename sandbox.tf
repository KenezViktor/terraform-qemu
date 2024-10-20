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
}

resource "libvirt_cloudinit_disk" "commoninit-sandbox" {
  count = var.number_of_sandboxes
  name = "commoninit-sandbox-${count.index}.iso"
  pool = "default"
  user_data = "${data.template_file.user_data-sandbox[count.index].rendered}"
}

resource "libvirt_domain" "sandbox" {
  count = var.number_of_sandboxes
  name = join("", [var.sandbox_subdomain, count.index, var.domain_name])
  memory = 2048
  vcpu = 2

  cloudinit = "${libvirt_cloudinit_disk.commoninit-sandbox[count.index].id}"

  network_interface {
    network_id = libvirt_network.sandbox.id
    hostname = join("", [var.sandbox_subdomain, count.index, var.domain_name])
    addresses = [ join("", [var.sandbox-network.ipv4, (count.index + 100)]) ]
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

  depends_on = [ libvirt_network.sandbox ]
}

# wait until VMs become ready
resource "terraform_data" "sandbox-up" {
  count = var.number_of_sandboxes

  # deletes old hostkey
  provisioner "local-exec" {
    command = "ssh-keygen -f ~/.ssh/known_hosts -R ${join("", [var.sandbox_subdomain, count.index, var.domain_name])}"
  }

  # waits util ssh becomes ready
  provisioner "local-exec" {
    command = "until nc -zv ${join("", [var.sandbox_subdomain, count.index, var.domain_name])} 22; do sleep 15; done"
  }

  # adds new ssh hostkeys
  provisioner "local-exec" {
    command = "ssh-keyscan -t rsa -H ${join("", [var.sandbox_subdomain, count.index, var.domain_name])} >> ~/.ssh/known_hosts"
  }

  depends_on = [ libvirt_domain.sandbox ]
}

# Run ansible
resource "terraform_data" "sandbox-ansible" {
  provisioner "local-exec" {
    command = "ansible-playbook -i inventory.yml --diff ${var.ansible_playbook_path}/sandbox-servers.yml"
  }

  depends_on = [ terraform_data.sandbox-up, ansible_group.sandbox, ansible_host.sandbox ]

}