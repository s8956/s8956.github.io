<#PSScriptInfo
  .VERSION      0.1.0
  .GUID         5d2bddd9-4eed-42f0-a0ba-7d30efcb81e2
  .AUTHOR       Kitsune Solar
  .AUTHOREMAIL  mail@kitsune.solar
  .COMPANYNAME  iHub TO
  .COPYRIGHT    2023 iHub TO. All rights reserved.
  .LICENSEURI   https://choosealicense.com/licenses/mit/
  .PROJECTURI   https://lib.onl/ru/posts/2023/10/616da78a-eb16-575a-9119-65f0c0c7baee/
#>

#Requires -Version 7.2
#Requires -RunAsAdministrator

<#
  .SYNOPSIS
  Changing the RDP port number.

  .DESCRIPTION
  Changing the listening port for Remote Desktop on your computer.

  .PARAMETER P_Port
  RDP port number.
  Default: 3389.

  .EXAMPLE
  .\pwsh.rdp.port.ps1 -P 50102

  .LINK
  https://lib.onl/ru/posts/2023/10/616da78a-eb16-575a-9119-65f0c0c7baee/
#>

Param(
  [Parameter(HelpMessage="RDP port number.")]
  [ValidatePattern('^[0-9]+$')]
  [Alias('P')][int]$P_Port = 3389
)

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-Script() {
  Set-RdpRegistry
  Set-RdpFirewall
  Restart-RdpService
}

# -------------------------------------------------------------------------------------------------------------------- #
# EDITING THE REGISTRY.
# -------------------------------------------------------------------------------------------------------------------- #

function Set-RdpRegistry() {
  $Param = @{
    Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\Terminal Server\WinStations\RDP-Tcp'
    Name = 'PortNumber'
    Value = $P_Port
  }

  Set-ItemProperty @Param
}

# -------------------------------------------------------------------------------------------------------------------- #
# EDITING THE FIREWALL.
# -------------------------------------------------------------------------------------------------------------------- #

function Set-RdpFirewall() {
  $TCP = @{
    DisplayName = 'RDPPORTLatest-TCP-In'
    Profile = 'Public'
    Direction = Inbound
    Action = Allow
    Protocol = TCP
    LocalPort = $P_Port
  }

  $UDP = @{
    DisplayName = 'RDPPORTLatest-UDP-In'
    Profile = 'Public'
    Direction = Inbound
    Action = Allow
    Protocol = UDP
    LocalPort = $P_Port
  }

  New-NetFirewallRule @TCP
  New-NetFirewallRule @UDP
}

# -------------------------------------------------------------------------------------------------------------------- #
# RESTARTING THE REMOTE DESKTOP SERVICES.
# -------------------------------------------------------------------------------------------------------------------- #

function Restart-RdpService() {
  $Param = @{
    Name = 'TermService'
  }

  Restart-Service @Param
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Start-Script
