provider "proxmox" {
  # All three required values are read from environment variables — no
  # secrets are hardcoded here.
  #
  # PROXMOX_VE_ENDPOINT   = "https://192.168.0.3:8006/"
  # PROXMOX_VE_API_TOKEN  = "<user>@<realm>!<tokenid>=<secret>"
  # PROXMOX_VE_INSECURE   = "true"   (skips TLS cert verification)

  # Required for disk clone operations. The provider SSHes into the Proxmox
  # host to run commands the REST API cannot handle (e.g. disk imports).
  # agent = true requires SSH_AUTH_SOCK to be set in the running shell;
  # reading the key file directly works regardless of agent availability.
  ssh {
    username    = "root"
    private_key = file("~/.ssh/id_ed25519")
  }
}
