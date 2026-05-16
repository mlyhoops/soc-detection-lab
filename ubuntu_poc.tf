# Downloads the Ubuntu 24.04 (Noble) cloud image to Proxmox local storage.
# This runs once; Terraform tracks it as a managed resource. The image is
# stored as an ISO on the 'local' datastore and referenced by the VM disk below.
resource "proxmox_virtual_environment_download_file" "ubuntu_24_04" {
  node_name    = var.proxmox_node
  content_type = "iso"
  datastore_id = var.image_storage

  url       = "https://cloud-images.ubuntu.com/noble/current/noble-server-cloudimg-amd64.img"
  file_name = "noble-server-cloudimg-amd64.img"
  overwrite = false
}

resource "proxmox_virtual_environment_vm" "ubuntu_poc" {
  name      = "ubuntu-poc"
  node_name = var.proxmox_node
  vm_id     = 200

  # q35 is the modern QEMU machine type (vs i440fx); better PCIe support.
  machine         = "q35"
  stop_on_destroy = true

  operating_system {
    type = "l26" # Linux 2.6+ kernel
  }

  # QEMU guest agent lets Proxmox (and Terraform) query the VM's IP address
  # and issue clean shutdown commands. Installed by vendor_cloud_init below.
  agent {
    enabled = true
  }

  cpu {
    cores = 2
    type  = "x86-64-v2-AES"
  }

  memory {
    dedicated = 2048
  }

  # The disk clones from the downloaded cloud image. 'fast-thin' is lvmthin,
  # which supports thin-provisioned VM disks. Size is in GiB.
  disk {
    datastore_id = var.vm_storage
    file_id      = proxmox_virtual_environment_download_file.ubuntu_24_04.id
    interface    = "scsi0"
    size         = 20
  }

  initialization {
    datastore_id = var.vm_storage

    # vendor_data installs the QEMU guest agent on first boot (see cloud_init.tf).
    # user_account handles SSH key injection — these two layers are merged by
    # cloud-init and do not conflict.
    vendor_data_file_id = proxmox_virtual_environment_file.vendor_cloud_init.id

    ip_config {
      ipv4 {
        address = "dhcp"
      }
    }

    user_account {
      username = "ubuntu"
      keys     = [var.ssh_public_key]
    }
  }

  network_device {
    bridge = var.network_bridge
    model  = "virtio"
  }

  boot_order = ["scsi0"]
}
