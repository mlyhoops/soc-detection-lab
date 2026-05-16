# Vendor-data is the platform layer of cloud-init — it runs alongside (and
# is merged with) the per-VM user-data. Using vendor_data_file_id here means
# every VM in this lab gets the guest agent without any per-VM config changes.
#
# Prerequisites: the snippet_storage pool must have the 'snippets' content
# type enabled. On the Proxmox host, run once:
#   pvesm set local --content iso,backup,vztmpl,snippets
resource "proxmox_virtual_environment_file" "vendor_cloud_init" {
  content_type = "snippets"
  datastore_id = var.snippet_storage
  node_name    = var.proxmox_node

  source_raw {
    data = <<-EOT
      #cloud-config
      packages:
        - qemu-guest-agent
      runcmd:
        - systemctl enable qemu-guest-agent
        - systemctl start qemu-guest-agent
    EOT
    file_name = "vendor-base.yaml"
  }
}
