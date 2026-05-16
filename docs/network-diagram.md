# Network Diagram

## Topology

```mermaid
graph TB
    internet((Internet))

    subgraph home["Home LAN — 192.168.0.0/24 — vmbr0"]
        router["Home Router\n192.168.0.1"]
        pve["Proxmox VE 9.0.3\n192.168.0.3"]
        webserv1["webserv1\nUbuntu 24.04\n192.168.0.53\nSplunk + Terraform"]
    end

    subgraph lab["Isolated Lab — 10.10.10.0/24 — vmbr1 — NAT outbound only"]
        dc01["dc01\nWin Server 2022\n10.10.10.10 — static"]
        win1["win11-01\nWindows 11\nDHCP 10.10.10.100-200"]
        win2["win11-02\nWindows 11\nDHCP 10.10.10.100-200"]
        kali["kali\nKali Linux\n10.10.10.250 — static"]
    end

    internet --> router --> pve
    pve -.->|"vmbr0 — management"| webserv1
    pve ==>|"vmbr1 — NAT"| dc01
    pve ==>|"vmbr1 — NAT"| win1
    pve ==>|"vmbr1 — NAT"| win2
    pve ==>|"vmbr1 — NAT"| kali
    dc01 & win1 & win2 -->|"TCP 9997\nSysmon + UF"| webserv1
```

---

## IP address table

| Host | Interface | Address | Assignment | Role |
|---|---|---|---|---|
| Home router | — | 192.168.0.1 | Static (ISP/router) | Default gateway, home LAN DHCP |
| Proxmox VE | vmbr0 | 192.168.0.3 | Static | Hypervisor management |
| Proxmox VE | vmbr1 | 10.10.10.1 | Static | Lab NAT gateway |
| webserv1 | eth0 | 192.168.0.53 | Static | Automation host, Splunk SIEM |
| dc01 | eth0 | 10.10.10.10 | Static (cloud-init) | Domain Controller, DNS, DHCP for lab subnet |
| win11-01 | eth0 | 10.10.10.100–200 | DHCP (from dc01) | Domain workstation |
| win11-02 | eth0 | 10.10.10.100–200 | DHCP (from dc01) | Domain workstation |
| kali | eth0 | 10.10.10.250 | Static (cloud-init) | Attacker machine |

---

## Bridge summary

| Bridge | Type | Subnet | Purpose | Internet access |
|---|---|---|---|---|
| vmbr0 | Linux bridge | 192.168.0.0/24 | Home LAN — management plane, webserv1 | Yes (via home router) |
| vmbr1 | Linux bridge + NAT | 10.10.10.0/24 | Isolated lab — all lab VMs | Outbound only (NAT via vmbr0) |
