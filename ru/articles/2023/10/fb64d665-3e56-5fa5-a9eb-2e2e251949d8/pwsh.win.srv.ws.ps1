<#PSScriptInfo
  .VERSION      0.1.0
  .GUID         c050355b-ecbd-4b13-b805-3a422dc0c995
  .AUTHOR       z17CX
  .AUTHOREMAIL  mail@z17.cx
  .COMPANYNAME  Library Online
  .COPYRIGHT    2023 Library Online. All rights reserved.
  .LICENSEURI   https://choosealicense.com/licenses/mit/
  .PROJECTURI   https://lib.onl/ru/articles/2023/10/fb64d665-3e56-5fa5-a9eb-2e2e251949d8/
#>

#Requires -Version 7.2
#Requires -RunAsAdministrator

<#
  .SYNOPSIS
  Windows Server configuration script.

  .DESCRIPTION
  The script allows you to set up Windows Server as a workstation.

  .EXAMPLE
  .\pwsh.win.srv.ws.ps1

  .LINK
  https://lib.onl/ru/articles/2023/10/fb64d665-3e56-5fa5-a9eb-2e2e251949d8/
#>

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-Script() {
  Start-FeatureConfig
  Start-ServiceConfig
  Start-IEConfig
  Start-PriorityControlConfig
  Start-MMAgentConfig
  Start-DEPConfig
}

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURING FEATURES.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-FeatureConfig {
  $Param = @{
    Name = 'Wireless-Networking'
  }

  Install-WindowsFeature @Param
}

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURING SERVICES.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-ServiceConfig() {
  $Name = @('Audiosrv', 'AudioEndpointBuilder')

  $Name | ForEach-Object {
    $Param = @{
      Name = "${_}"
      StartupType = 'Automatic'
    }

    Set-Service @Param
  }

  $WSearch = @{
    Name = 'WSearch'
    StartupType = 'AutomaticDelayedStart'
  }

  Set-Service @WSearch
}

# -------------------------------------------------------------------------------------------------------------------- #
# DISABLE IE ENHANCED SECURITY CONFIGURATION (ESC).
# -------------------------------------------------------------------------------------------------------------------- #

function Start-IEConfig() {
  $Path = @(
    'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A7-37EF-4b3f-8CFC-4F3A74704073}'
    'HKLM:\SOFTWARE\Microsoft\Active Setup\Installed Components\{A509B1A8-37EF-4b3f-8CFC-4F3A74704073}'
  )

  $Path | ForEach-Object {
    $Param = @{
      LiteralPath = "${_}"
      Name = 'IsInstalled'
      Value = 0
    }

    if (Test-Path -LiteralPath "${_}") {
      Set-ItemProperty @Param
      Write-Host 'IE Enhanced Security Configuration (ESC) has been disabled.'
    } else {
      Write-Error -Message "'${_}' not found!" -ErrorAction 'Stop'
    }
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# ADJUST PROCESSOR RESOURCES FOR BEST PERFORMANCE OF PROGRAMS.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-PriorityControlConfig() {
  $Path = 'HKLM:\SYSTEM\CurrentControlSet\Control\PriorityControl'

  $Param = @{
    LiteralPath = "${Path}"
    Name = 'Win32PrioritySeparation'
    Value = 38
  }

  if (Test-Path -LiteralPath "${Path}") {
    Set-ItemProperty @Param
  } else {
    Write-Error -Message "'${Path}' not found!" -ErrorAction 'Stop'
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURING MMAGENT.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-MMAgentConfig() {
  $Param = @{
    MemoryCompression = $true
    OperationAPI = $true
    PageCombining = $true
  }

  Enable-MMAgent @Param
}

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURING DEP.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-DEPConfig() {
  cmd.exe /c 'bcdedit.exe /set {current} nx OptIn'
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Start-Script
