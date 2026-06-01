# Run this in PowerShell on each Windows VM from the Proxmox VNC console.
# Enables WinRM so Ansible can connect. Lab use only — not hardened for production.

Enable-PSRemoting -SkipNetworkProfileCheck -Force
Set-Item WSMan:\localhost\Service\AllowUnencrypted -Value true
Set-Item WSMan:\localhost\Service\Auth\Basic -Value true
netsh advfirewall firewall add rule name="WinRM-HTTP" dir=in action=allow protocol=TCP localport=5985
Restart-Service WinRM
Write-Host "WinRM ready. Ansible can now connect on port 5985."
