# Runbook

Operational reference for managing and rebuilding the detection lab.

---

## Prerequisites

Before running any Terraform commands, verify the following on **webserv1** (192.168.0.53):

```bash
# Proxmox API credentials must be set
echo $PROXMOX_VE_ENDPOINT    # should be https://192.168.0.3:8006/
echo $PROXMOX_VE_API_TOKEN   # should be non-empty
echo $PROXMOX_VE_INSECURE    # should be true

# Splunk should be running
/opt/splunk/bin/splunk status

# Confirm the UF listener is up
ss -tlnp | grep 9997
```

Add the three `PROXMOX_VE_*` variables to your shell profile (`~/.bashrc` or `~/.zshrc`) so they persist across sessions.

---

## Start the lab

The lab VMs are managed by Terraform. To bring everything up from a clean state:

```bash
cd ~/detection-lab
terraform init        # only needed once, or after provider version changes
terraform plan        # review what will be created
terraform apply       # provision all VMs
```

After apply completes, confirm VMs are running in the Proxmox web UI at `https://192.168.0.3:8006/`.

To start VMs that already exist in Terraform state without reprovisioning:

```bash
# From Proxmox host — start a specific VM by ID
ssh root@192.168.0.3 "qm start <vmid>"
```

---

## Stop the lab

**Option A — Stop VMs without destroying state** (preferred for daily use):

```bash
ssh root@192.168.0.3 "qm stop 201 202 203 204"   # adjust VM IDs to match your state
```

This preserves disk state and Terraform state. VMs can be restarted with `qm start`.

**Option B — Full destroy** (use only when rebuilding from scratch):

```bash
cd ~/detection-lab
terraform destroy
```

This removes all VMs and their disks from Proxmox. The downloaded cloud image (`local:iso/noble-server-cloudimg-amd64.img`) is retained — it is managed as a separate resource and will not be re-downloaded on the next apply.

---

## Rebuild from scratch

Full rebuild sequence after a `terraform destroy`:

```bash
# 1. Re-provision infrastructure
cd ~/detection-lab
terraform apply

# 2. Run Ansible to configure the domain, Sysmon, and Splunk UF
#    (Ansible playbooks added in Session 3)
cd ~/detection-lab/ansible
ansible-playbook site.yml

# 3. Verify Splunk is receiving events
#    Open https://localhost:8000 → Search → index=sysmon | head 10

# 4. Confirm domain join on workstations
#    RDP into win11-01 → run: whoami /fqdn
```

---

## Where credentials live

| Credential | Location | Notes |
|---|---|---|
| Proxmox API token | Environment variables on webserv1 | Add to `~/.bashrc`; never commit to git |
| Proxmox root SSH key | `~/.ssh/id_ed25519` on webserv1 | Used by Terraform's bpg/proxmox SSH block |
| Splunk admin password | Set during Splunk install | Stored in Splunk's local credential store |
| Windows domain admin | Set during dc01 Ansible play | Document in a local password manager, not in this repo |
| Lab VM local accounts | Set via cloud-init `user_account` | SSH key-based for Linux; password for Windows (Ansible-managed) |

No secrets are committed to this repository. The `.gitignore` excludes `*.tfvars`, `*.tfstate`, and `*.tfstate.*`.

---

## Onboard a new attack tool

When adding a new tool to the lab (e.g., a new Atomic Red Team module, a custom script):

1. **Check egress** — Confirm the tool does not exfiltrate data or beacon outbound. The vmbr1 NAT provides isolation but does not block all outbound traffic.
2. **Install on kali** — Add the tool to the Ansible `kali` role so it is present after every rebuild. Do not rely on manual installs that do not survive `terraform destroy`.
3. **Test in isolation** — Run the tool against a single target VM before running it against the full domain.
4. **Document in the detection writeup** — Add the tool to the "Tools used" table in the relevant `detections/T[ID]-*/README.md`.

---

## Troubleshooting

### First-time setup issues

These are the issues most likely to appear during initial deployment. They will not recur after the first successful build.

| Symptom | Cause | Fix |
|---|---|---|
| `terraform apply` fails: `unable to authenticate user "root" over SSH` | Terraform's bpg/proxmox provider uses its own SSH client, not the system `ssh-agent`. `SSH_AUTH_SOCK` is not set in non-interactive shells. | Use `private_key = file("~/.ssh/id_ed25519")` in the provider's `ssh` block. Do **not** use `agent = true`. |
| `terraform apply` fails: `storage 'local' does not support content-type 'images'` | `initialization.datastore_id` is set to `local`, which only supports `iso`/`backup`/`vztmpl` by default. | Set `initialization.datastore_id` to `fast-thin` (lvmthin supports `images` content). |
| `terraform apply` fails: `storage 'local' does not support content-type 'snippets'` | The `local` storage does not have snippets enabled. | On the Proxmox host: `pvesm set local --content iso,backup,vztmpl,snippets` |
| Terraform hangs for 10–15 min waiting for QEMU agent, then times out with empty IP output | Ubuntu 24.04 cloud images do not include `qemu-guest-agent` pre-installed. | Ensure `vendor_data_file_id` references the `vendor_cloud_init` snippet, which installs and starts the agent on first boot. Run `terraform refresh` after the VM finishes booting to populate IP output. |
| `terraform plan` fails: `401 Unauthorized` | API token is missing, expired, or the token ID/secret format is wrong. | Format must be `user@realm!tokenid=secret`. Verify with `curl -k -H "Authorization: PVEAPIToken=$PROXMOX_VE_API_TOKEN" $PROXMOX_VE_ENDPOINT/api2/json/version` |

### Ongoing operations issues

Issues that may appear during normal lab use after initial setup.

| Symptom | Cause | Fix |
|---|---|---|
| Splunk not receiving events from a Windows VM | Splunk UF service stopped, or the VM was rebuilt and UF needs to be redeployed | Check UF service on the Windows VM: `Get-Service SplunkForwarder`. Re-run the Ansible UF playbook if needed. |
| VM unreachable after reboot | DHCP lease expired or changed | Check the Proxmox console for the current IP, or query the QEMU agent: `ssh root@192.168.0.3 "qm guest cmd <vmid> network-get-interfaces"` |
| `terraform plan` shows unexpected resource changes | Proxmox made out-of-band changes (e.g., snapshots, manual VM edits) | Review the diff carefully. Run `terraform refresh` to sync state before deciding whether to apply. |
| Windows VM clock drift causing Kerberos failures | VM time not synced | Enable NTP on dc01 and ensure workstations sync from the DC. Check with `w32tm /query /status` on the affected host. |
