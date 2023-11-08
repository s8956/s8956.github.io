<#PSScriptInfo
  .VERSION      0.1.0
  .GUID         52672f5d-e2c0-467a-ae1d-c0fc9009a1eb
  .AUTHOR       Kitsune Solar
  .AUTHOREMAIL  mail@kitsune.solar
  .COMPANYNAME  Library Online
  .COPYRIGHT    2023 Library Online. All rights reserved.
  .LICENSEURI   https://choosealicense.com/licenses/mit/
  .PROJECTURI   https://lib.onl/ru/articles/2023/10/38fc94dd-8d37-5f9e-b556-676304976a9f/
#>

#Requires -Version 7.2
#Requires -RunAsAdministrator

<#
  .SYNOPSIS
  Testing and repairing the secure channel between the local computer and its domain.

  .DESCRIPTION
  Verifying that the channel between the local computer and its domain is working correctly by checking the status of its trust relationships. If a connection fails, trying to restore it.

  .PARAMETER P_Server
  Specifies the domain controller to run the command. If this parameter is not specified, this script selects a default domain controller for the operation.

  .PARAMETER P_Sleep
  Sleep time (in seconds).

  .EXAMPLE
  .\pwsh.csc.repair.ps1

  .EXAMPLE
  .\pwsh.csc.repair.ps1 -DC 'DC-server.domain.com'

  .LINK
  https://lib.onl/ru/articles/2023/10/38fc94dd-8d37-5f9e-b556-676304976a9f/
#>

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION.
# -------------------------------------------------------------------------------------------------------------------- #

Param(
  [Parameter(HelpMessage="Specifies the domain controller to run the command.")]
  [Alias('DC')][string]$P_Server,

  [Parameter(HelpMessage="Sleep time (in seconds).")]
  [Alias('S')][int]$P_Sleep = 5
)

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-Script() {
  Start-CSCRepair
}

# -------------------------------------------------------------------------------------------------------------------- #
# EDITING THE REGISTRY.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-CSCRepair() {
  $Param = @{
    Server = "${P_Server}"
    Repair = $true
    Credential = (Get-Credential)
  }

  do {
    if (Test-ComputerSecureChannel) {
      Write-Host 'Connection successful. Everything is fine!'
    } else {
      Write-Host 'Connection failed! The secure channel between the local computer and the domain is broken. Removing and then rebuilds the channel established by the NetLogon service...'
      Test-ComputerSecureChannel @Param
      Start-Sleep -s $P_Sleep
    }
  } until (Test-ComputerSecureChannel)
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Start-Script
