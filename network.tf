resource "libvirt_network" "sandbox" {
  name = "sandbox"
  mode = "nat"

  domain = var.domain_name
  addresses = [ join("" ,[var.sandbox-network.network, var.sandbox-network.netmask]) ]

  dhcp {
    enabled = false
  }

  dns {
    enabled = true
  }
}