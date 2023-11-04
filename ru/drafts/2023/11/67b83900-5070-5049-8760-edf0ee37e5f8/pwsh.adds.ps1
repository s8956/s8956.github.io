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

function Start-Script() {
  Start-SrvAddsInstall
  Start-SrvAddsForest
}

# -------------------------------------------------------------------------------------------------------------------- #
#
# -------------------------------------------------------------------------------------------------------------------- #

function Start-SrvAddsInstall() {
  Param(
    [Alias('N')][string]$Name = 'AD-Domain-Services'
  )

  Install-WindowsFeature -Name "${Name}"
}

# -------------------------------------------------------------------------------------------------------------------- #
#
# -------------------------------------------------------------------------------------------------------------------- #

function Start-SrvAddsForest() {
  Param(
    [Parameter(Mandatory)][Alias('DN')][string]$DomainName,
    [Parameter(Mandatory)][Alias('DNN')][string]$DomainNetBiosName,
    [Alias('DCM')][int]$DCMode = 7,
    [Alias('SD')][string]$SrvDir = 'D:\SRV\ADDS'
  )

  [string]$PWD = Read-Host -Prompt 'Administrator password' -AsSecureString

  $ADDSForest = @{
    DomainName = "${DomainName}"
    DomainMode = $DCMode
    ForestMode = $DCMode
    DomainNetbiosName = "${DomainNetBiosName}"
    DatabasePath = "${SrvDir}\NTDS"
    SysvolPath = "${SrvDir}\SYSVOL"
    LogPath = "${SrvDir}\Logs"
    SafeModeAdministratorPassword = "${PWD}"
    CreateDNSDelegation = $false
    InstallDNS = $false
    NoRebootOnCompletion = $true
    Force = $true
  }

  Install-ADDSForest @ADDSForest
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Start-Script
