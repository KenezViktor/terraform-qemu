resource "ansible_group" "sandbox" {
  name = "sandbox-servers"
  variables = {
    ansible_user = "root"
  }
}

resource "ansible_host" "sandbox" {
  count = var.number_of_sandboxes
  name = join("", [var.sandbox_subdomain, count.index, var.domain_name])
  groups = [ ansible_group.sandbox.name ]
}
/*
resource "ansible_playbook" "sandbox" {
  count = var.number_of_sandboxes
  playbook   = join("/", [var.ansible_playbook_path, "sandbox-servers.yml"])
  name       = data.template_file.user_data-sandbox[count.index].vars.hostname
  #groups = [ ansible_group.sandbox.name ]
  groups = [ "sandbox-servers" ]
  replayable = true
  diff_mode = true
  extra_vars = {
    ansible_user = "root"
  }
}
*/