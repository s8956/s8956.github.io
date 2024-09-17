<#PSScriptInfo
.VERSION      0.1.0
.GUID         41643d28-3808-4a6f-a322-d87ed4384d5f
.AUTHOR       Kai Kimera
.AUTHOREMAIL  mail@kai.kim
.COMPANYNAME  Library Online
.COPYRIGHT    2023 Library Online. All rights reserved.
.LICENSEURI   https://choosealicense.com/licenses/mit/
.PROJECTURI   https://lib.onl/ru/2023/10/1f062637-3227-56d7-93e3-126d1c80f5a8/
#>

#Requires -Version 7.2
#Requires -RunAsAdministrator

<#
.SYNOPSIS
Setting PATH variable for system.

.DESCRIPTION
The script configures the PATH variable values for the system.

.EXAMPLE
.\pwsh.set.env.path.system.ps1 -P 'C:\Apps\App_01', 'C:\Apps\App_02', 'C:\Apps\App_03'

.LINK
https://lib.onl/ru/2023/10/1f062637-3227-56d7-93e3-126d1c80f5a8/
#>

Param(
  [Alias('P')][string[]]$Path
)

function Set-EnvPathSystem() {
  $Path | ForEach-Object {
    [Environment]::SetEnvironmentVariable(
      'Path', ([Environment]::GetEnvironmentVariables('Machine')).Path + "${_}" + [IO.Path]::PathSeparator, 'Machine'
    )
  }
}

Set-EnvPathSystem
