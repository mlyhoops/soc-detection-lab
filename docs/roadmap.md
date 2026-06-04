# Roadmap

Session-by-session build plan. Each session has a defined scope and produces a meaningful, standalone commit. This document is the single source of truth for project status.

---

## Session 1 — Foundation ✅ Complete

**Goal:** Prove the full Terraform → Proxmox automation pipeline works before writing any lab VMs.

- [x] Scaffold Terraform project (`versions.tf`, `provider.tf`, `variables.tf`, `cloud_init.tf`)
- [x] Configure bpg/proxmox provider using environment variables (no hardcoded secrets)
- [x] Confirm provider authenticates to Proxmox VE 9.0.3 with a no-op `terraform plan`
- [x] Download Ubuntu 24.04 Noble cloud image to Proxmox `local` storage
- [x] Provision proof-of-concept VM (ubuntu-poc, VM 200) with cloud-init, DHCP, SSH key injection
- [x] Resolve SSH auth issue: `agent = true` does not work in non-interactive shells; switched to `private_key = file()`
- [x] Resolve storage content-type issues: cloud-init drive on `fast-thin`; snippets enabled on `local`
- [x] Establish cloud-init vendor-data pattern (`vendor_data_file_id`) for guest agent installation
- [x] Confirm SSH access to ubuntu-poc as `ubuntu` user
- [x] Write project documentation (this repo)

**Note:** `ubuntu-poc` (VM 200) is a temporary validation artifact. It will be torn down at the start of Session 2 with `terraform destroy -target proxmox_virtual_environment_vm.ubuntu_poc`.

---

## Session 2 — Isolated Network + Windows Domain Controller ✅ Complete

**Goal:** Create the isolated lab network and provision the domain controller.

- [x] Destroy ubuntu-poc (skipped — state was empty; POC validated in Session 1)
- [x] Create vmbr1 bridge on Proxmox host (10.10.10.0/24)
- [x] Configure NAT from vmbr1 to vmbr0 on the Proxmox host
- [x] Add `vm_bridge_lab` variable pointing to vmbr1
- [x] Download Windows Server 2022 evaluation ISO to Proxmox storage
- [x] Provision dc01 VM (2 vCPU / 4 GB / 60 GB, static IP 10.10.10.10, vmbr1)
- [x] Validate dc01 is reachable from webserv1 via the lab network (ARP REACHABLE; ICMP blocked by Windows Firewall — expected)
- [x] Add persistent 10.10.10.0/24 route on webserv1 via netplan

---

## Session 3 — Domain Setup + Endpoint Logging ✅ Complete

**Goal:** Build the Active Directory domain and get Sysmon telemetry flowing into Splunk.

- [x] Provision win11-01 (VM 202) and win11-02 (VM 203) — Windows Server 2022 Desktop Experience (Win11 ISO rejected due to TPM enforcement in QEMU)
- [x] Promote dc01 to domain controller (lab.local), configure DNS + DHCP for 10.10.10.0/24
- [x] Domain-join win11-01 and win11-02
- [x] Deploy Sysmon64 (lab-focused config) on dc01, win11-01, win11-02
- [x] Deploy Splunk UF 10.4.0 on all Windows hosts, forwarding to webserv1:9997
- [x] Confirm `index=sysmon` and `index=wineventlog` receiving events from all three hosts
- [x] Fix: renderXml=false for correct EventCode field extraction; Event Log Readers group for Sysmon access

---

## Session 4 — Attacker Setup + Attack Infrastructure Validation ✅ Complete

**Goal:** Provision the Kali attacker VM and validate the full lab attack chain.

- [x] Provision kali VM (Kali 2026.1, vmbr1, static IP 10.10.10.250) — imported from QEMU image, no manual install
- [x] Install PowerShell + Invoke-AtomicRedTeam 2.3.0 via Ansible
- [x] Install CrackMapExec, nmap, netcat, impacket via Ansible
- [x] Confirm Sysmon Event ID 1 (EventCode=1) visible in `index=sysmon` end-to-end
- [x] All four lab VMs healthy: dc01, win11-01, win11-02, kali

---

## Session 5 — Detection: T1078 Valid Accounts ⬜ Pending

**Goal:** Build and document the password spray detection.

- [ ] Run Atomic Red Team T1078 simulation from kali against dc01
- [ ] Identify the relevant Windows Security Event IDs (4625 failed logons, 4648 explicit credentials)
- [ ] Build SPL detection query, validate against simulated events
- [ ] Tune false positive thresholds
- [ ] Write `detections/T1078-valid-accounts/README.md` (full template)
- [ ] Write `detections/T1078-valid-accounts/attack.md`
- [ ] Save final SPL to `detections/T1078-valid-accounts/detection.spl`
- [ ] Capture screenshots

---

## Session 6 — Detection: T1059.001 PowerShell ⬜ Pending

**Goal:** Detect suspicious PowerShell execution via Sysmon and script block logging.

- [ ] Enable PowerShell script block logging via Group Policy on dc01
- [ ] Run Atomic Red Team T1059.001 simulation
- [ ] Identify relevant events: Sysmon Event ID 1 (process create), Event ID 4104 (script block)
- [ ] Build SPL query correlating process name, command line, and script block content
- [ ] Full writeup, attack doc, SPL save, screenshots

---

## Session 7 — Detection: T1003.001 LSASS Memory Dump ⬜ Pending

**Goal:** Detect Mimikatz-style LSASS access via Sysmon Event ID 10.

- [ ] Run Atomic Red Team T1003.001 (Mimikatz sekurlsa::logonpasswords or procdump against LSASS)
- [ ] Identify Sysmon Event ID 10 (process access) with TargetImage = lsass.exe
- [ ] Build SPL query filtering on suspicious source processes and access rights mask
- [ ] Full writeup, attack doc, SPL save, screenshots

---

## Session 8 — Detection: T1021.002 SMB Lateral Movement ⬜ Pending

**Goal:** Detect SMB-based lateral movement via Windows logon event correlation.

- [ ] Simulate lateral movement from kali to win11-01 using SMB (PsExec, smbclient, or Atomic Red Team)
- [ ] Identify Event ID 4624 (logon type 3 — network) on target host
- [ ] Build SPL query correlating source IP, logon type, and target host over time
- [ ] Full writeup, attack doc, SPL save, screenshots

---

## Session 9 — Detection: T1486 Ransomware Behavior ⬜ Pending

**Goal:** Detect ransomware-like file encryption behavior via mass Sysmon file creation events.

- [ ] Simulate ransomware behavior using a benign script that rapidly creates/renames files (Atomic Red Team T1486 or custom)
- [ ] Identify Sysmon Event ID 11 (file create) at high volume from a single process
- [ ] Build SPL query with time-window aggregation: process creating > N files in M seconds
- [ ] Full writeup, attack doc, SPL save, screenshots

---

## Session 10 — Portfolio Polish ⬜ Pending

**Goal:** Make the repo ready to link from a resume or LinkedIn.

- [ ] Add status badges to `README.md` (all five detections showing complete)
- [ ] Verify all Mermaid diagrams render correctly on GitHub
- [ ] Review all writeups for consistency and completeness
- [ ] Ensure all screenshots are captured and committed
- [ ] Final `terraform plan` shows no unexpected drift
- [ ] Tag the repo: `git tag v1.0`

---

## Summary

| Session | Focus | Status |
|---|---|---|
| 1 | Terraform scaffold, provider auth, POC VM, project docs | ✅ Complete |
| 2 | vmbr1 isolated network, dc01 VM | ✅ Complete |
| 3 | Domain setup, Sysmon + UF via Ansible | ✅ Complete |
| 4 | Kali VM, Atomic Red Team, end-to-end validation | ✅ Complete |
| 5 | Detection: T1078 Valid Accounts | ⬜ Pending |
| 6 | Detection: T1059.001 PowerShell | ⬜ Pending |
| 7 | Detection: T1003.001 LSASS Dump | ⬜ Pending |
| 8 | Detection: T1021.002 SMB Lateral Movement | ⬜ Pending |
| 9 | Detection: T1486 Ransomware Behavior | ⬜ Pending |
| 10 | Portfolio polish, screenshots, v1.0 tag | ⬜ Pending |
