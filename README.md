## About

This project is all about playing with Terraform, cloud-init and Debian's cloud image on Qemu/KVM environment.

Anyone planning to learn Terraform locally will(hopefully) find this project useful.

## Steps to run

### Install Terraform

Offical site link: https://developer.hashicorp.com/terraform/tutorials/aws-get-started/install-cli

After that run this to ensure it's installation:

```terraform --version```

### Install Qemu/KVM

Before installation, check if virtualization is enabled:

```lscpu | grep '^Virt'```

The output should show either ```VT-x``` or ```AMD-V```

For Debian/Ubuntu you can use this quide: https://www.tecmint.com/install-qemu-kvm-ubuntu-create-virtual-machines/

For other distros, follow their specific guide, however it should be a similar process.

For reasons, terraform might not be able to access the VMs it created(permission denied).

To resolve this, you need to edit the following file:

```/etc/libvirt/qemu.conf```

Find the line ```#security_driver = "selinux"``` and change it to ```security_driver = "none"```. You will need elevated privileges to do so.

Restart related services:
```
sudo systemctl restart libvirt-bin
sudo systemctl restart libvirtd
sudo systemctl restart qemu
```

The permission denied problem should be solved.

### Download Debian image

Run the following script with elevated privileges if required:

```sudo ./get-debian-cloudimg```

You can copy it to your path:
```
sudo cp get-debian-cloudimg /usr/local/bin/get-debian-cloudimg
```

You can also create a cronjob for it:
```
0 2 * * * /usr/local/bin/get-debian-cloudimg
```

### Run Terraform

Get the provider for libvirt and cloud-init:

```terraform init```

Check if everything works:

```terraform plan```

Create the VMs:

```terraform apply```

If you have ```virt-manager``` installed, you can check the process there. The VMs will reboot to apply network config, after that you will be able to access them via ssh. Check the ```sandbox.tf``` file for the IP addresses.

To use hostnames instead of IP addresses use something like this:
```
sudo sh -c 'echo "\n#custom config\n192.168.122.151\tsandbox-0.home.lab\n192.168.122.152\tsandbox-1.home.lab" >> /etc/hosts'
```

## Config for Ansible

### Install collection

For Ansible in order to use the dynamically generated inventory run the following
```
ansible-galaxy collection install cloud.terraform
```

## TODO

- experiment with cloud-init
