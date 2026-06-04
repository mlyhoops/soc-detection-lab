# Attack Simulation — T1059.001 PowerShell

## Environment

| | |
|---|---|
| Attacker | webserv1 (192.168.0.53) via Ansible WinRM |
| Target | win11-01 (10.10.10.11) |
| Credential used | WIN11-01\Administrator |
| Technique | Remote PowerShell execution with suspicious flags |

## Execution

```bash
ansible win11-01 -m ansible.windows.win_shell \
  -a 'powershell -nop -NonInteractive -c "Write-Host T1059001-sim; New-Object System.Net.WebClient | Out-Null"' \
  -e @ansible/group_vars/secrets.yml
```

## Sysmon Event Captured

```
EventCode:        1
ComputerName:     win11-01.lab.local
Image:            C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
CommandLine:      "C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe"
                  -nop -NonInteractive -c
                  "Write-Host T1059001-sim; New-Object System.Net.WebClient | Out-Null"
User:             WIN11-01\Administrator
IntegrityLevel:   High
ProcessId:        1972
ParentImage:      C:\Windows\System32\WindowsPowerShell\v1.0\powershell.exe
ParentCommandLine: "powershell.exe" -noninteractive -encodedcommand <base64>
```

## Detection Indicators

| Field | Value | Why it matters |
|---|---|---|
| `Image` | `powershell.exe` | Direct PowerShell invocation |
| `CommandLine` | contains `-nop` | No-profile flag — suppresses profile scripts, common in offensive tooling |
| `CommandLine` | contains `WebClient` | Download cradle pattern — `New-Object Net.WebClient` used to fetch remote payloads |
| `IntegrityLevel` | High | Elevated execution — attacker has admin rights on the endpoint |
| `ParentCommandLine` | `-encodedcommand ...` | Parent was also a suspicious PowerShell — indicates chained execution |

## What to look for in Splunk

```spl
index=sysmon host=win11-01 EventCode=1 Image="*\\powershell.exe"
(CommandLine="* -nop *" OR CommandLine="*WebClient*" OR CommandLine="*EncodedCommand*")
| table _time, host, User, CommandLine
| sort - _time
```
