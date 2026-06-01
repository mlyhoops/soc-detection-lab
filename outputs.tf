output "dc01_vm_id" {
  description = "dc01 VM ID — find it in the Proxmox web UI under this ID"
  value       = proxmox_virtual_environment_vm.dc01.vm_id
}
