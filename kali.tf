resource "proxmox_virtual_environment_vm" "kali" {
  name      = "kali"
  node_name = var.proxmox_node
  vm_id     = 204

  machine         = "q35"
  stop_on_destroy = true

  operating_system {
    type = "l26"
  }

  agent {
    enabled = false
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 4096
  }

  # Disk imported from Kali QEMU image via: qm importdisk 204 kali-linux-2026.1-qemu-amd64.qcow2 fast-thin
  disk {
    datastore_id = var.vm_storage
    interface    = "scsi0"
    size         = 80
    file_format  = "qcow2"
  }

  network_device {
    bridge = var.vm_bridge_lab
    model  = "e1000e"
  }

  boot_order = ["scsi0"]
}
