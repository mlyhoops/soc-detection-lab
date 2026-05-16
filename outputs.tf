output "ubuntu_poc_vm_id" {
  description = "VM ID — find the VM in the Proxmox web UI under this ID"
  value       = proxmox_virtual_environment_vm.ubuntu_poc.vm_id
}

output "ubuntu_poc_ipv4_addresses" {
  description = "All IPv4 addresses reported by the QEMU guest agent (includes 127.0.0.1)"
  value       = proxmox_virtual_environment_vm.ubuntu_poc.ipv4_addresses
}
