variable "proxmox_node" {
  description = "Proxmox node name (hostname of the PVE host)"
  type        = string
  default     = "proxmox"
}

variable "vm_storage" {
  description = "Storage pool for VM disk images (lvmthin)"
  type        = string
  default     = "fast-thin"
}

variable "image_storage" {
  description = "Storage pool for downloaded cloud images (dir type, supports ISO content)"
  type        = string
  default     = "local"
}

variable "network_bridge" {
  description = "Network bridge for VM network interfaces"
  type        = string
  default     = "vmbr0"
}

variable "ssh_public_key" {
  description = "SSH public key injected into VMs via cloud-init"
  type        = string
  default     = "ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIDuVFARuRuIiwVPSxAI4m2CNXPdZvJ5NyyX/PWX9VLxo mlyhoops@gmail.com"
}

variable "snippet_storage" {
  description = "Storage pool for cloud-init snippet files (dir type, must have snippets content enabled)"
  type        = string
  default     = "local"
}
