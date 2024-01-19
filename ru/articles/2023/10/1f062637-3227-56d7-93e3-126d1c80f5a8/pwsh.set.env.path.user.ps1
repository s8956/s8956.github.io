<#PSScriptInfo
  .VERSION      0.1.0
  .GUID         79f23918-308a-412c-8835-b1bb9c9193e3
  .AUTHOR       Kai Kimera
  .AUTHOREMAIL  mail@kai.kim
  .COMPANYNAME  Library Online
  .COPYRIGHT    2023 Library Online. All rights reserved.
  .LICENSEURI   https://choosealicense.com/licenses/mit/
  .PROJECTURI   https://lib.onl/ru/articles/2023/10/1f062637-3227-56d7-93e3-126d1c80f5a8/
#>

#Requires -Version 7.2

<#
  .SYNOPSIS
  Setting PATH variable for user.

  .DESCRIPTION
  The script configures the PATH variable values for the user.

  .EXAMPLE
  .\pwsh.set.env.path.user.ps1 -P 'C:\Apps\App_01', 'C:\Apps\App_02', 'C:\Apps\App_03'

  .LINK
  https://lib.onl/ru/articles/2023/10/1f062637-3227-56d7-93e3-126d1c80f5a8/
#>

Param(
  [Alias('P')][string[]]$Path
)

function Set-EnvPathUser() {
  $Path | ForEach-Object {
    [Environment]::SetEnvironmentVariable(
      'Path', ([Environment]::GetEnvironmentVariables('User')).Path + "${_}" + [IO.Path]::PathSeparator, 'User'
    )
  }
}

Set-EnvPathUser
