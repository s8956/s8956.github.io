<#PSScriptInfo
.VERSION      0.1.0
.GUID         f5e8380e-4e2f-4c58-972e-a60ace8dee8e
.AUTHOR       Kai Kimera
.AUTHOREMAIL  mail@kai.kim
.COMPANYNAME  Library Online
.COPYRIGHT    2024 Library Online. All rights reserved.
.TAGS         windows temp cleanup
.LICENSEURI   https://choosealicense.com/licenses/mit/
.PROJECTURI   https://lib.onl/ru/2024/09/aaef951a-9caf-5765-8189-c91f3f305821/
#>

<#
.SYNOPSIS
Script for deleting temporary data.

.DESCRIPTION
The script deletes data in the specified directories.

.EXAMPLE
.\app.temp.cleanup.ps1

.LINK
https://lib.onl/ru/2024/09/aaef951a-9caf-5765-8189-c91f3f305821/
#>

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION
# -------------------------------------------------------------------------------------------------------------------- #

$SystemTemp = @(
  "C:\Windows\Temp\*"
)

$ProfileTemp = @(
  "AppData\Local\Temp\*"
  "AppData\Local\Mozilla\Firefox\Profiles\*.default-release\cache2\entries\*"
  "AppData\Local\Microsoft\Windows\Explorer\*"
  "AppData\Roaming\Mozilla\Firefox\Profiles\*.default-release\storage\default\*"
  "AppData\Local\Google\Chrome\User Data\Default\Service Worker\CacheStorage\*"
  "AppData\Local\Google\Chrome\User Data\Default\Cache\Cache_Data\*"
  "AppData\Local\Google\Chrome\User Data\Default\Code Cache\js\*"
  "AppData\LocalLow\Adobe\Acrobat\DC\ConnectorIcons\*"
  "AppData\Local\Microsoft\Windows\INetCache\Content.Outlook\*"
)

$ProfileExclude = @(
  'Администратор'
  'Administrator'
  'Setup'
  'Public'
  'All Users'
  'Default User'
)

$ProfileList = 'HKLM:\SOFTWARE\Microsoft\Windows NT\CurrentVersion\ProfileList'
$Profiles = Get-ChildItem (Get-ItemProperty -Path "${ProfileList}").ProfilesDirectory -Exclude $ProfileExclude

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION
# -------------------------------------------------------------------------------------------------------------------- #

function Start-Script() {
  Start-CleanUp
}

# -------------------------------------------------------------------------------------------------------------------- #
# CLEANUP
# -------------------------------------------------------------------------------------------------------------------- #

function Start-CleanUp() {
  ForEach ($Path in $SystemTemp) {
    Remove-Data -Path "${Path}"
  }

  ForEach ($Profile in $Profiles) {
    ForEach ($Path in $ProfileTemp) {
      $Path = (Join-Path -Path "${Profile}" -ChildPath "${Path}")
      if (Test-Path -Path "${Path}") { Remove-Data -Path "${Path}" }
    }
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------< COMMON FUNCTIONS >------------------------------------------------ #
# -------------------------------------------------------------------------------------------------------------------- #

function Remove-Data() {
  Param(
    [string]$Path
  )

  Remove-Item -Path "${Path}" -Recurse -Force -ErrorAction 'SilentlyContinue'
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Start-Script
