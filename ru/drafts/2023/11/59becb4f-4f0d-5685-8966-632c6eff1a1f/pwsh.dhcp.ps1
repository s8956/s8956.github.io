<#PSScriptInfo
  .VERSION      0.1.0
  .GUID
  .AUTHOR       Kitsune Solar
  .AUTHOREMAIL  mail@kitsune.solar
  .COMPANYNAME  iHub TO
  .COPYRIGHT    2023 iHub TO. All rights reserved.
  .LICENSEURI   https://choosealicense.com/licenses/mit/
  .PROJECTURI
#>

#Requires -Version 7.2

<#
  .SYNOPSIS

  .DESCRIPTION

  .EXAMPLE

  .LINK
#>

Param(
  [Alias('ScopeStartRange')]
  [IPAddress]$P_ScopeStartRange = 10.0.100.1,

  [Alias('ScopeEndRange')]
  [IPAddress]$P_ScopeEndRange = 10.0.200.254,

  [Alias('ScopeMask')]
  [IPAddress]$P_ScopeMask = 255.255.0.0,

  [Alias('ScopeID')]
  [IPAddress]$P_ScopeID = 10.0.0.0,

  [Alias('DNSServer')]
  [IPAddress[]]$P_DNSServer = (10.0.5.3, 10.0.4.3),

  [Parameter(Mandatory)]
  [Alias('DNSDomain')]
  [String]$P_DNSDomain,

  [Alias('Gateway')]
  [IPAddress[]]$P_Gateway = 10.0.0.1
)

function Start-Script() {
  Start-SrvDhcpInstall
  Start-SrvDhcpDatabase
  Start-SrvDhcpScope
  Start-SrvDhcpOptionValue
  Start-SrvDhcpInDC
}

# -------------------------------------------------------------------------------------------------------------------- #
#
# -------------------------------------------------------------------------------------------------------------------- #

function Start-SrvDhcpInstall() {
  Install-WindowsFeature -Name 'DHCP'
}

# -------------------------------------------------------------------------------------------------------------------- #
#
# -------------------------------------------------------------------------------------------------------------------- #

function Start-SrvDhcpDatabase() {
  $DhcpServerDatabase = @{
    FileName = 'D:\SRV\DHCP\DHCP.mdb'
    BackupPath = 'D:\SRV\DHCP\Backup'
    BackupInterval = 30
    CleanupInterval = 120
  }

  Set-DhcpServerDatabase @DhcpServerDatabase
}

# -------------------------------------------------------------------------------------------------------------------- #
#
# -------------------------------------------------------------------------------------------------------------------- #

function Start-SrvDhcpScope() {
  $Scope99 = @{
    Name = 'Main'
    StartRange = $P_ScopeStartRange
    EndRange = $P_ScopeEndRange
    SubnetMask = $P_ScopeMask
  }

  Add-DhcpServerv4Scope @Scope99
}

# -------------------------------------------------------------------------------------------------------------------- #
#
# -------------------------------------------------------------------------------------------------------------------- #

function Start-SrvDhcpOptionValue() {
  $DhcpServerv4OptionValue = @{
    ScopeId = $P_ScopeID
    DnsServer = $P_DNSServer
    DnsDomain = "${P_DNSDomain}"
    Router = $P_Gateway
  }

  Set-DhcpServerv4OptionValue @DhcpServerv4OptionValue
}

# -------------------------------------------------------------------------------------------------------------------- #
#
# -------------------------------------------------------------------------------------------------------------------- #

function Start-SrvDhcpInDC() {
  $DhcpServerInDC = @{
    DnsName = "${P_DnsName}"
    IPAddress = $P_IP
  }

  Add-DhcpServerInDC @DhcpServerInDC
  Add-DhcpServerSecurityGroup
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Start-Script
