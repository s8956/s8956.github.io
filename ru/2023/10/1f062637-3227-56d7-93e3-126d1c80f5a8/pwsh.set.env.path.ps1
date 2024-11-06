<#PSScriptInfo
.VERSION      0.1.0
.GUID         14efdc7d-1edd-4b40-b6d2-623288ce1659
.AUTHOR       Kai Kimera
.AUTHOREMAIL  mail@kai.kim
.COMPANYNAME  Library Online
.COPYRIGHT    2023 Library Online. All rights reserved.
.LICENSEURI   https://choosealicense.com/licenses/mit/
.PROJECTURI   https://lib.onl/ru/2023/10/1f062637-3227-56d7-93e3-126d1c80f5a8/
#>

#Requires -Version 7.2

<#
.SYNOPSIS
Setting the PATH variable.

.DESCRIPTION
The script configures the PATH variable values.

.EXAMPLE
.\pwsh.set.env.path.ps1 -P 'C:\Apps\App_01', 'C:\Apps\App_02', 'C:\Apps\App_03' -T 'Machine'

.EXAMPLE
.\pwsh.set.env.path.ps1 -P 'C:\Apps\App_01', 'C:\Apps\App_02', 'C:\Apps\App_03' -T 'User'

.LINK
https://lib.onl/ru/2023/10/1f062637-3227-56d7-93e3-126d1c80f5a8/
#>


param(
  [Alias('P')][string[]]$Path,
  [Parameter(Mandatory)][ValidateSet('Machine', 'User')][Alias('T')][string[]]$Target
)

function Set-EnvPath() {
  $Path | ForEach-Object {
    [Environment]::SetEnvironmentVariable(
      'Path', ([Environment]::GetEnvironmentVariables("${Target}")).Path + "${_}" + [IO.Path]::PathSeparator, "${Target}"
    )
  }
}

Set-EnvPath
