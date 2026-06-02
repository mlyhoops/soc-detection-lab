resource "proxmox_virtual_environment_vm" "win11_01" {
  name      = "win11-01"
  node_name = var.proxmox_node
  vm_id     = 202

  machine         = "q35"
  stop_on_destroy = true

  operating_system {
    type = "win11"
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

  disk {
    datastore_id = var.vm_storage
    interface    = "sata0"
    size         = 50
  }

  cdrom {
    file_id   = "local:iso/windows-server-2022.iso"
    interface = "ide2"
  }

  network_device {
    bridge = var.vm_bridge_lab
    model  = "e1000e"
  }

  boot_order = ["sata0"]
}

resource "proxmox_virtual_environment_vm" "win11_02" {
  name      = "win11-02"
  node_name = var.proxmox_node
  vm_id     = 203

  machine         = "q35"
  stop_on_destroy = true

  operating_system {
    type = "win11"
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

  disk {
    datastore_id = var.vm_storage
    interface    = "sata0"
    size         = 50
  }

  cdrom {
    file_id   = "local:iso/windows-server-2022.iso"
    interface = "ide2"
  }

  network_device {
    bridge = var.vm_bridge_lab
    model  = "e1000e"
  }

  boot_order = ["sata0"]
}
