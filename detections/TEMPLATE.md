# T[ID] — [Technique Name]

**MITRE ATT&CK:** [T[ID]](https://attack.mitre.org/techniques/T[ID]/)
**Tactic:** [e.g., Credential Access]
**Platforms:** Windows

---

## Description

What this technique is and why it matters to defenders. Describe the attacker goal (2–3 sentences). Explain what artifact or behavior makes this detectable.

---

## Attack simulation

### Tools used

| Tool | Purpose |
|---|---|
| Atomic Red Team | Automated technique execution |
| [Additional tool] | [Purpose] |

### Steps to reproduce

1. Ensure lab prerequisites are met (see [detections/README.md](../README.md#lab-prerequisites)).
2. From the kali VM (or the Windows endpoint for local execution):

```bash
# Atomic Red Team invocation
Invoke-AtomicTest T[ID] -TestNumbers [N]
```

3. [Additional manual steps if needed]

### Expected endpoint behavior

Describe what happens on the target machine: process created, file written, network connection made, registry key modified, etc. This is what the analyst should expect to see in Sysmon or Windows Event Log before searching Splunk.

---

## Data sources required

| Source | Splunk Index | Event IDs / Sourcetype | Required config |
|---|---|---|---|
| Windows Security Log | `wineventlog` | [e.g., 4624, 4625] | Default — no extra config |
| Sysmon | `sysmon` | [e.g., Event ID 1, 10] | Sysmon installed with SwiftOnSecurity config |
| [Other source] | [index] | [events] | [config needed] |

---

## Detection logic

```spl
index=sysmon OR index=wineventlog
[field]="[value]"
| [additional filters]
| stats count by [fields]
| where count > [threshold]
| table [output fields]
```

### Logic explanation

Walk through each clause of the SPL:

- **`index=...`** — Scope to the relevant indexes.
- **`[field]="[value]"`** — Filter on the characteristic indicator for this technique.
- **`stats count by ...`** — Aggregate to surface patterns rather than individual events.
- **`where count > N`** — Threshold that separates malicious volume from normal behavior.

---

## False positive considerations

| Scenario | Likelihood | Tuning recommendation |
|---|---|---|
| [Benign trigger] | Low / Medium / High | [How to filter or adjust threshold] |
| [Benign trigger] | Low / Medium / High | [How to filter or adjust threshold] |

---

## Recommended response

Describe the decision tree an analyst should follow when this alert fires:

1. **Triage** — Confirm the alert is not a known false positive (check the table above).
2. **Investigate** — Pivot to the endpoint: [specific pivot steps].
3. **Escalate if** — List conditions that warrant immediate escalation (e.g., LSASS access from an unexpected process, successful auth after spray).
4. **Contain** — [Isolation or remediation steps].

---

## References

- [MITRE ATT&CK T[ID]](https://attack.mitre.org/techniques/T[ID]/)
- [Atomic Red Team T[ID]](https://github.com/redcanaryco/atomic-red-team/blob/master/atomics/T[ID]/T[ID].md)
- [Additional reference]

---

## Screenshots

### Splunk search result

![Splunk search showing detection](screenshots/splunk-search.png)

*Caption: [Describe what the screenshot shows — e.g., "Sysmon Event 10 showing unexpected process accessing LSASS memory"]*

### Event detail

![Sysmon or Windows Event Log detail](screenshots/event-detail.png)

*Caption: [Describe the specific event fields that confirm the technique]*
