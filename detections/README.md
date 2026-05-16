# Detection Portfolio

This directory contains detection engineering writeups for five MITRE ATT&CK techniques. Each technique has a dedicated subdirectory with attack simulation steps, validated Splunk detection logic, and response guidance.

## What is MITRE ATT&CK?

[MITRE ATT&CK](https://attack.mitre.org/) is a publicly maintained knowledge base of adversary tactics, techniques, and procedures (TTPs) observed in real-world intrusions. Each technique is assigned a unique ID (e.g., T1078) and describes *what* an attacker does, not the specific malware or tool used. Detections built against ATT&CK techniques are more durable than detections built against specific indicators of compromise (IOCs), which adversaries rotate frequently.

## Techniques

| MITRE ID | Technique | Tactic | Summary | Status |
|---|---|---|---|---|
| [T1078](T1078-valid-accounts/) | Valid Accounts | Initial Access, Persistence | Detect password spray attempts against Active Directory accounts | ⬜ Pending |
| [T1059.001](T1059.001-powershell/) | PowerShell | Execution | Detect suspicious PowerShell via Sysmon Event 1 and script block logging | ⬜ Pending |
| [T1003.001](T1003.001-lsass-dump/) | LSASS Memory | Credential Access | Detect Mimikatz-style LSASS access via Sysmon Event 10 | ⬜ Pending |
| [T1021.002](T1021.002-smb-lateral-movement/) | SMB/Windows Admin Shares | Lateral Movement | Detect lateral movement via Event ID 4624 logon type 3 correlation | ⬜ Pending |
| [T1486](T1486-ransomware/) | Data Encrypted for Impact | Impact | Detect ransomware behavior via mass Sysmon Event 11 file creates from a single process | ⬜ Pending |

## Lab prerequisites

All of the following must be in place before running any attack simulation:

- [ ] dc01 provisioned and promoted to domain controller
- [ ] win11-01 and win11-02 domain-joined
- [ ] Sysmon (SwiftOnSecurity config) deployed on dc01, win11-01, win11-02
- [ ] Splunk Universal Forwarder installed and shipping to webserv1:9997
- [ ] Splunk indexes `wineventlog` and `sysmon` created and receiving events
- [ ] Atomic Red Team installed on kali (and optionally on the Windows endpoints for local execution)

## How to use these writeups

Each detection follows the same lifecycle:

1. **Simulate** — Run the attack using Atomic Red Team or the manual steps in `attack.md`
2. **Validate** — Confirm the expected events appear in Splunk within the correct index
3. **Detect** — Build and tune the SPL query in `detection.spl`
4. **Document** — Fill in the technique `README.md` using [TEMPLATE.md](TEMPLATE.md) as the guide
5. **Screenshot** — Capture the Splunk search result and save to `screenshots/`
