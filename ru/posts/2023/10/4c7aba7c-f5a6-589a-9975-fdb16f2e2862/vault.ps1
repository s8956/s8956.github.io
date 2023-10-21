<#PSScriptInfo
  .VERSION      0.1.0
  .GUID         8fd0ce2c-0288-4d9c-805f-703a0c659ade
  .AUTHOR       mail@kitsune.solar
  .COMPANYNAME  iHub TO
  .COPYRIGHT    2023 iHub TO. All rights reserved.
  .LICENSEURI   https://choosealicense.com/licenses/mit/
#>

#Requires -Version 7.2

<#
  .SYNOPSIS
  PowerShell "Vault".

  .DESCRIPTION
  The script moves files to Vault based on various criteria.

  .PARAMETER Mode
  Script operation mode. Default: 'MV'.

  .PARAMETER Source
  Path to the source. E.g.: 'C:\Data\Source'.

  .PARAMETER Destination
  Path to the Vault. E.g.: 'C:\Data\Vault'.

  .PARAMETER 7zip
  Path to the directory with the '7za.exe' file.. E.g.: 'C:\Apps\7z'.

  .PARAMETER CreationTime
  Time since file creation (in seconds). E.g.: '5270400'. Default: 61 day (5270400 sec.).

  .PARAMETER LastWriteTime
  Time since file modification (in seconds). E.g.: '5270400'. Default: 61 day ('5270400' sec.).

  .PARAMETER FileSize
  File size check. E.g.: '5kb' / '12mb'. Default: '0kb'.

  .PARAMETER Exclude
  Path to the file with exceptions. E.g.: 'C:\Data\exclude.txt'.

  .PARAMETER Logs
  Path to the directory with logs. E.g.: 'C:\Data\Logs'.

  .PARAMETER RemoveDirs
  Removing empty directories.

  .PARAMETER Overwrite
  Overwrite existing files in Vault.

  .EXAMPLE
  .\vault.ps1 -SRC 'C:\Data' -DST 'C:\Vault'

  .EXAMPLE
  .\vault.ps1 -SRC 'C:\Data' -DST 'C:\Vault' -CT '864000' -WT '864000'

  .EXAMPLE
  .\vault.ps1 -SRC 'C:\Data' -DST 'C:\Vault' -CT '864000' -WT '864000' -FS '32mb'

  .LINK
  Library Online: https://lib.onl/ru/posts/2023/10/4c7aba7c-f5a6-589a-9975-fdb16f2e2862/
#>

Param(
  [Parameter(HelpMessage="Script operation mode. Default: 'MV'.")]
  [ValidateSet('CP', 'MV', 'RM')][Alias('M')][string]$Mode = 'MV',

  [Parameter(HelpMessage="Path to the source. E.g.: 'C:\Data\Source'.")]
  [Alias('SRC', 'Data')][string]$Source = "${PSScriptRoot}\Source",

  [Parameter(HelpMessage="Path to the Vault. E.g.: 'C:\Data\Vault'.")]
  [Alias('DST', 'Vault')][string]$Destination = "${PSScriptRoot}\Vault",

  [Parameter(HelpMessage="Path to the directory with the '7za.exe' file.. E.g.: 'C:\Apps\7z'.")]
  [Alias('7z')][string]$7zip = "${PSScriptRoot}\Apps\7z",

  [Parameter(HelpMessage="Time since file creation (in seconds). E.g.: '5270400'. Default: 61 day (5270400 sec.).")]
  [Alias('CT', 'Create')][long]$CreationTime = 5270400,

  [Parameter(HelpMessage="Time since file modification (in seconds). E.g.: '5270400'. Default: 61 day ('5270400' sec.).")]
  [Alias('WT', 'Modify')][long]$LastWriteTime = 5270400,

  [Parameter(HelpMessage="File size check. E.g.: '5kb' / '12mb'. Default: '0kb'.")]
  [Alias('FS', 'Size')][string]$FileSize = '0kb',

  [Parameter(HelpMessage="Path to the file with exceptions. E.g.: 'C:\Data\exclude.txt'.")]
  [Alias('E')][string]$Exclude = "${PSScriptRoot}\vault.exclude.txt",

  [Parameter(HelpMessage="Path to the directory with logs. E.g.: 'C:\Data\Logs'.")]
  [Alias('L')][string]$Logs = "${PSScriptRoot}\Logs",

  [Parameter(HelpMessage="Removing empty directories.")]
  [Alias('RD')][switch]$RemoveDirs = $false,

  [Parameter(HelpMessage="Overwrite existing files in Vault.")]
  [Alias('O')][switch]$Overwrite = $false
)

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION.
# -------------------------------------------------------------------------------------------------------------------- #

# Timestamp.
$TS = (Get-Date -Format 'yyyy-MM-dd.HH-mm-ss')

# New line separator.
$NL = ([Environment]::NewLine)

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-Vault() {
  Start-VaultCheck
  Start-VaultGetFiles
  if ($RemoveDirs) { Start-VaultRemoveDirs }
}

# -------------------------------------------------------------------------------------------------------------------- #
# CREATE VAULT DIRECTORIES.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-VaultCheck() {
  $Dirs = @("${Source}", "${Destination}", "${7zip}")
  $Files = @("${Exclude}")
  $7za = @('7za.dll', '7za.exe', '7zxa.dll')

  foreach ($Dir in $Dirs) { if (-not (Test-Path "${Dir}")) { New-Item -Path "${Dir}" -ItemType 'Directory' } }
  foreach ($File in $Files) { if (-not (Test-Path "${File}")) { New-Item -Path "${File}" -ItemType 'File' } }
  foreach ($7za in $7za) { if (-not (Test-Path "${7zip}\${7za}")) {
    Write-VaultMsg -T 'W' `
      -M ("'${7za}' not found!${NL}${NL}" +
      "1. Download '7-Zip Extra' from 'https://www.7-zip.org/download.html'.${NL}" +
      "2. Extract all contents into a directory '${7zip}'.${NL}${NL}" +
      "Example: '${7zip}\${7za}'") `
      -A 'Inquire'
  } }
}

# -------------------------------------------------------------------------------------------------------------------- #
# MOVE FILES TO VAULT.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-VaultGetFiles() {
  Write-VaultMsg -T 'HL' -M 'Moving files to Vault'

  $Items = (Get-ChildItem -Path "${Source}" -Recurse -Exclude (Get-Content "${Exclude}")
    | Where-Object {
        (-not ($_.PSIsContainer)) `
        -and (($_.CreationTime) -lt ((Get-Date).AddSeconds(-$CreationTime))) `
        -and (($_.LastWriteTime) -lt ((Get-Date).AddSeconds(-$LastWriteTime)))
      }
    | Where-Object {
        (($_.Length) -ge "${FileSize}")
      })

  if (-not $Items) { Write-VaultMsg -T 'I' -M 'Required files were not found in the source!' }

  foreach ($Item in $Items) {
    if (($Item.FullName.Length) -ge 245) {
      Write-VaultMsg -T 'W' -M "'${Item}' has over 250 characters in path! Skip..."
      continue
    }

    $Dir  = "$($Item.Directory.ToString())"
    $File = "$($Item.FullName.Remove(0, $Source.Length))"
    $Path = "${Destination}${File}"

    switch ($Mode) {
      'CP' {
        New-SimilarDirectory -P "${Destination}" -N "${Dir}"
        Backup-SimilarFile -P "${Path}" -N "${Path}.VAULT.${TS}.7z"

        Write-VaultMsg -M "[CP] '${Item}' -> '${Path}'"
        Copy-Item -Path "$($Item.FullName)" -Destination "${Path}" -Force
      }
      'MV' {
        New-SimilarDirectory -P "${Destination}" -N "${Dir}"
        Backup-SimilarFile -P "${Path}" -N "${Path}.VAULT.${TS}.7z"

        Write-VaultMsg -M "[MV] '${Item}' -> '${Path}'"
        Move-Item -Path "$($Item.FullName)" -Destination "${Path}" -Force
      }
      'RM' {
        Write-VaultMsg -M "[RM] '${Item}'"
        Remove-Item -Path "$($Item.FullName)" -Force
      }
    }
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# REMOVE EMPTY DIRECTORIES.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-VaultRemoveDirs() {
  Write-VaultMsg -T 'HL' -M 'Removing empty directories'

  $Items = (Get-ChildItem -Path "${Source}" -Recurse
    | Where-Object {
        ($_.PSIsContainer) `
        -and (($_.CreationTime) -lt ((Get-Date).AddSeconds(-$CreationTime))) `
        -and (($_.LastWriteTime) -lt ((Get-Date).AddSeconds(-$LastWriteTime))) `
      })

  if (-not $Items) { Write-VaultMsg -T 'I' -M 'No empty directories were found in the source!' }

  foreach ($Item in $Items) {
    if (((Get-ChildItem "${Item}" | Measure-Object).Count) -eq 0) {
      Write-VaultMsg -M "[RM] '${Item}'"
      Remove-Item -Path "${Item}" -Force
    }
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# CREATE SIMILAR DIRECTORIES.
# -------------------------------------------------------------------------------------------------------------------- #

function New-SimilarDirectory() {
  param (
    [Alias('P')][string]$Path,
    [Alias('N')][string]$Name
  )

  New-Item -Path "${Path}" -ItemType 'Directory' `
    -Name "$($Name.Remove(0, $Source.Length))" -ErrorAction 'SilentlyContinue'
}

# -------------------------------------------------------------------------------------------------------------------- #
# BACKUP SIMILAR FILES.
# -------------------------------------------------------------------------------------------------------------------- #

function Backup-SimilarFile() {
  param (
    [Alias('P')][string]$Path,
    [Alias('N')][string]$Name
  )

  if (-not $Overwrite -and (Test-Path "${Path}")) {
    Compress-7z -T '7z' -L 9 -I "${Path}" -O "${Name}"
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# MESSAGES.
# -------------------------------------------------------------------------------------------------------------------- #

function Write-VaultMsg() {
  param (
    [Alias('M')][string]$Message,
    [Alias('T')][string]$Type,
    [Alias('A')][string]$Action = 'Continue'
  )

  switch ($Type) {
    'HL'    { Write-Host "${NL}--- ${Message}".ToUpper() -ForegroundColor Blue }
    'I'     { Write-Information -MessageData "${Message}" -InformationAction "${Action}" }
    'W'     { Write-Warning -Message "${Message}" -WarningAction "${Action}" }
    'E'     { Write-Error -Message "${Message}" -ErrorAction "${Action}" }
    default { Write-Host "${Message}" }
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# 7Z: COMPRESS.
# -------------------------------------------------------------------------------------------------------------------- #

function Compress-7z() {
  param (
    [Alias('I')][string]$In,
    [Alias('O')][string]$Out,
    [ValidateSet('7z', 'BZIP2', 'GZIP', 'TAR', 'WIM', 'XZ', 'ZIP')][Alias('T')][string]$Type = '7z',
    [ValidateRange(1,9)][Alias('L')][int]$Level = 5
  )

  $CMD = @('a', "-t${Type}", "-mx${Level}", "${Out}", "${In}")
  & "${7zip}\7za.exe" $CMD
}

# -------------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------------< INIT >------------------------------------------------------ #
# -------------------------------------------------------------------------------------------------------------------- #

Start-Transcript -Path "${Logs}\$((Get-Date).Year)\$((Get-Date).Month)\${TS}.log"
Start-Vault
Stop-Transcript
