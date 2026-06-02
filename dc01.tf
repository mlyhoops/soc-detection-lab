resource "proxmox_virtual_environment_vm" "dc01" {
  name      = "dc01"
  node_name = var.proxmox_node
  vm_id     = 201

  machine         = "q35"
  stop_on_destroy = true

  operating_system {
    type = "win11"  # win11 covers Windows Server 2022 — same kernel generation
  }

  # Agent disabled until Windows is installed and QEMU guest tools are set up.
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

  # SATA interface: Windows sees SATA natively — no VirtIO drivers needed during install.
  disk {
    datastore_id = var.vm_storage
    interface    = "sata0"
    size         = 60
  }

  # Windows Server 2022 Evaluation ISO. Upload to Proxmox local storage before applying.
  # Rename the downloaded ISO to exactly "WinServer2022Eval.iso" before uploading.
  cdrom {
    file_id   = "local:iso/windows-server-2022.iso"
    interface = "ide2"
  }


  # e1000e: Windows-visible NIC — no VirtIO drivers needed during initial install.
  network_device {
    bridge = var.vm_bridge_lab
    model  = "e1000e"
  }

  boot_order = ["sata0"]
}
