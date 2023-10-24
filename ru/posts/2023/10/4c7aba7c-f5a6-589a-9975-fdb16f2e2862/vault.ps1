<#PSScriptInfo
  .VERSION      0.1.3
  .GUID         8fd0ce2c-0288-4d9c-805f-703a0c659ade
  .AUTHOR       Kitsune Solar
  .AUTHOREMAIL  mail@kitsune.solar
  .COMPANYNAME  iHub TO
  .COPYRIGHT    2023 iHub TO. All rights reserved.
  .LICENSEURI   https://choosealicense.com/licenses/mit/
  .PROJECTURI   https://lib.onl/ru/posts/2023/10/4c7aba7c-f5a6-589a-9975-fdb16f2e2862/
#>

#Requires -Version 7.2

<#
  .SYNOPSIS
  PowerShell "Vault".

  .DESCRIPTION
  The script moves files to Vault based on various criteria.

  .PARAMETER P_Mode
  Script operation mode.
  Default: 'MV'.

  .PARAMETER P_Source
  Path to the source. E.g.: 'C:\Data\Source'.
  Default: '${PSScriptRoot}\Source'.

  .PARAMETER P_Vault
  Path to the Vault. E.g.: 'C:\Data\Vault'.
  Default: '${PSScriptRoot}\Vault'.

  .PARAMETER P_CreationTime
  Time since file creation (in seconds). E.g.: '5270400'.
  Default: '5270400' (61 day).

  .PARAMETER P_LastWriteTime
  Time since file modification (in seconds). E.g.: '5270400'.
  Default: '${P_CreationTime}'.

  .PARAMETER P_FileSize
  File size check. E.g.: '5kb' / '12mb'.
  Default: '0kb'.

  .PARAMETER P_Exclude
  Path to the file with exceptions. E.g.: 'C:\Data\exclude.txt'.
  Default: '${PSScriptRoot}\vault.exclude.txt'.

  .PARAMETER P_Logs
  Path to the directory with logs. E.g.: 'C:\Data\Logs'.
  Default: '${PSScriptRoot}\Logs'.

  .PARAMETER P_RemoveDirs
  Removing empty directories.
  Default: 'false'.

  .PARAMETER P_Overwrite
  Overwrite existing files in Vault.
  Default: 'false'.

  .EXAMPLE
  .\vault.ps1 -SRC 'C:\Data' -DST 'C:\Vault'

  .EXAMPLE
  .\vault.ps1 -SRC 'C:\Data' -DST 'C:\Vault' -CT '864000' -WT '864000'

  .EXAMPLE
  .\vault.ps1 -SRC 'C:\Data' -DST 'C:\Vault' -CT '864000' -WT '864000' -FS '32mb'

  .LINK
  https://lib.onl/ru/posts/2023/10/4c7aba7c-f5a6-589a-9975-fdb16f2e2862/
#>

Param(
  [Parameter(HelpMessage="Script operation mode. Default: 'MV'.")]
  [ValidateSet('CP', 'MV', 'RM')]
  [Alias('M')][string]$P_Mode = 'MV',

  [Parameter(HelpMessage="Path to the source. E.g.: 'C:\Data\Source'.")]
  [Alias('SRC')][string]$P_Source = "${PSScriptRoot}\Source",

  [Parameter(HelpMessage="Path to the Vault. E.g.: 'C:\Data\Vault'.")]
  [Alias('DST')][string]$P_Vault = "${PSScriptRoot}\Vault",

  [Parameter(HelpMessage="Time since file creation (in seconds). E.g.: '5270400'. Default: 61 day (5270400 sec.).")]
  [Alias('CT')][long]$P_CreationTime = 5270400,

  [Parameter(HelpMessage="Time since file modification (in seconds). E.g.: '5270400'. Default: 61 day ('5270400' sec.).")]
  [Alias('WT')][long]$P_LastWriteTime = $P_CreationTime,

  [Parameter(HelpMessage="File size check. E.g.: '5kb' / '12mb'. Default: '0kb'.")]
  [Alias('FS')][string]$P_FileSize = '0kb',

  [Parameter(HelpMessage="Path to the file with exceptions. E.g.: 'C:\Data\exclude.txt'.")]
  [Alias('E')][string]$P_Exclude = "${PSScriptRoot}\vault.exclude.txt",

  [Parameter(HelpMessage="Path to the directory with logs. E.g.: 'C:\Data\Logs'.")]
  [Alias('L')][string]$P_Logs = "${PSScriptRoot}\Logs",

  [Parameter(HelpMessage="Removing empty directories.")]
  [Alias('RD')][switch]$P_RemoveDirs = $false,

  [Parameter(HelpMessage="Overwrite existing files in Vault.")]
  [Alias('O')][switch]$P_Overwrite = $false
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

function Start-Script() {
  Test-Vault
  Move-Files
  if ($P_RemoveDirs) { Remove-Dirs }
}

# -------------------------------------------------------------------------------------------------------------------- #
# CREATING VAULT DIRECTORIES.
# -------------------------------------------------------------------------------------------------------------------- #

function Test-Vault() {
  $Dirs = @("${P_Source}", "${P_Vault}")
  $Files = @("${P_Exclude}")

  foreach ($Dir in $Dirs) {
    if (-not (Test-Data -T 'D' -P "${Dir}")) { New-Data -T 'D' -P "${Dir}" }
  }

  foreach ($File in $Files) {
    if (-not (Test-Data -T 'F' -P "${File}")) { New-Data -T 'F' -P "${File}" }
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# MOVING FILES TO VAULT.
# -------------------------------------------------------------------------------------------------------------------- #

function Move-Files() {
  Write-Msg -T 'HL' -M 'Moving files to Vault'

  $Files = ((Get-ChildItem -LiteralPath "${P_Source}" -Recurse -File -Exclude (Get-Content "${P_Exclude}"))
    | Where-Object { (($_.CreationTime) -lt ((Get-Date).AddSeconds(-$P_CreationTime))) `
      -and (($_.LastWriteTime) -lt ((Get-Date).AddSeconds(-$P_LastWriteTime))) }
    | Where-Object { ($_.Length) -ge "${P_FileSize}" })

  if (-not $Files) { Write-Msg -T 'I' -M "Required files were not found in the '${P_Source}'!" }

  $Files | ForEach-Object {
    $File = $_

    if (($File.FullName.Length) -ge 245) {
      Write-Msg -T 'W' -M "Over 250 characters in path! Skip:${NL}'${File}'"
      continue
    }

    # Getting information about the file path.
    # Example:
    #   Source path: 'C:\Data\Source'.
    #   Vault path: 'C:\Data\Vault'.
    #   File path in Source: 'C:\Data\Source\Dir_01\Dir_02\File.txt'.
    #   Values:
    #     $Path[0] | Path without Source and file name ('\Dir_01\Dir_02').
    #     $Path[1] | Path without Source and with file name ('\Dir_01\Dir_02\File.txt').

    $Path = @("$($File.DirectoryName)", "$($File.FullName)").ForEach({ $_.Remove(0, $P_Source.Length) })

    # Joining a Vault path.
    $Path[1] = (${P_Vault} | Join-Path -ChildPath "$($Path[1])")

    switch ($P_Mode) {
      'CP' {
        New-Data -T 'D' -P "${P_Vault}" -N "$($Path[0])"
        Compress-Data -P "$($Path[1])" -N "$($Path[1]).VAULT.${TS}.7z"

        Write-Msg -M "[CP] '$($File.FullName)' -> '$($Path[1])'"
        Copy-Item -LiteralPath "$($File.FullName)" -Destination "$($Path[1])" -Force
      }
      'MV' {
        New-Data -T 'D' -P "${P_Vault}" -N "$($Path[0])"
        Compress-Data -P "$($Path[1])" -N "$($Path[1]).VAULT.${TS}.7z"

        Write-Msg -M "[MV] '$($File.FullName)' -> '$($Path[1])'"
        Move-Item -LiteralPath "$($File.FullName)" -Destination "$($Path[1])" -Force
      }
      'RM' {
        Write-Msg -M "[RM] '$($File.FullName)'"
        Remove-Item -LiteralPath "$($File.FullName)" -Force
      }
    }
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# REMOVING EMPTY DIRECTORIES FROM SOURCE.
# -------------------------------------------------------------------------------------------------------------------- #

function Remove-Dirs() {
  Write-Msg -T 'HL' -M 'Removing empty directories'

  do {
    $Dirs = ((Get-ChildItem -LiteralPath "${P_Source}" -Recurse -Directory)
      | Where-Object { (($_.CreationTime) -lt ((Get-Date).AddSeconds(-$P_CreationTime))) `
        -and (($_.LastWriteTime) -lt ((Get-Date).AddSeconds(-$P_LastWriteTime))) }
      | Where-Object { ((Get-ChildItem $_.FullName -Force).Count) -eq 0 }
      | Select-Object -ExpandProperty 'FullName')

    if (-not $Dirs) { Write-Msg -T 'I' -M "No empty directories were found in the '${P_Source}'!" }

    $Dirs | ForEach-Object {
      $Dir = $_
      Write-Msg -M "[RM] '${Dir}'"
      Remove-Item -LiteralPath "${Dir}" -Force
    }
  } while ( $Dirs.Count -gt 0 )
}

# -------------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------< COMMON FUNCTIONS >------------------------------------------------ #
# -------------------------------------------------------------------------------------------------------------------- #

# -------------------------------------------------------------------------------------------------------------------- #
# TESTING ELEMENTS.
# -------------------------------------------------------------------------------------------------------------------- #

function Test-Data() {
  param (
    [Alias('T')][string]$P_Type,
    [Alias('P')][string]$P_Path
  )

  switch ($P_Type) {
    'D' { $P_Type = 'Container' }
    'F' { $P_Type = 'Leaf' }
  }

  Test-Path -LiteralPath "${P_Path}" -PathType "${P_Type}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# CREATING ELEMENTS.
# -------------------------------------------------------------------------------------------------------------------- #

function New-Data() {
  param (
    [Alias('T')][string]$P_Type,
    [Alias('P')][string]$P_Path,
    [Alias('N')][string]$P_Name,
    [Alias('A')][string]$P_Action = 'SilentlyContinue'
  )

  switch ($P_Type) {
    'D' { $P_Type = 'Directory' }
    'F' { $P_Type = 'File' }
  }

  New-Item -Path "${P_Path}" -Name "${P_Name}" -ItemType "${P_Type}" -ErrorAction "${P_Action}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# COMPRESSION ELEMENTS.
# -------------------------------------------------------------------------------------------------------------------- #

function Compress-Data() {
  param (
    [Alias('P')][string]$P_Path,
    [Alias('N')][string]$P_Name
  )

  if (-not $P_Overwrite -and (Test-Data -T 'F' -P "${P_Path}")) {
    Start-7z -T '7z' -L 9 -I "${P_Path}" -O "${P_Name}"
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# SYSTEM MESSAGES.
# -------------------------------------------------------------------------------------------------------------------- #

function Write-Msg() {
  param (
    [Alias('T')][string]$P_Type,
    [Alias('M')][string]$P_Message,
    [Alias('A')][string]$P_Action = 'Continue'
  )

  switch ($P_Type) {
    'HL'    { Write-Host "${NL}--- ${P_Message}".ToUpper() -ForegroundColor Blue }
    'I'     { Write-Information -MessageData "${P_Message}" -InformationAction "${P_Action}" }
    'W'     { Write-Warning -Message "${P_Message}" -WarningAction "${P_Action}" }
    'E'     { Write-Error -Message "${P_Message}" -ErrorAction "${P_Action}" }
    default { Write-Host "${P_Message}" }
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# APP: 7-ZIP.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-7z() {
  param (
    [Alias('I')][string]$P_In,
    [Alias('O')][string]$P_Out,
    [ValidateSet('7z', 'BZIP2', 'GZIP', 'TAR', 'WIM', 'XZ', 'ZIP')][Alias('T')][string]$P_Type = '7z',
    [ValidateRange(1,9)][Alias('L')][int]$P_Level = 5
  )

  # File list for '7za.exe'.
  $7z = @('7za.exe', '7za.dll', '7zxa.dll')

  # Search '7za.exe'.
  $7zExe = ((Get-ChildItem -LiteralPath "${PSScriptRoot}" -Filter "$($7z[0])" -Recurse -File) | Select-Object -First 1)

  # Getting '7za.exe' directory.
  $7zDir = ($7zExe.DirectoryName)

  # Checking the location of files.
  foreach ($File in $7z) {
    if (-not (Test-Data -T 'F' -P "${7zDir}\${File}")) {
      Write-Msg -T 'W' -A 'Stop' -M ("'${File}' not found!${NL}${NL}" +
      "1. Download 7-Zip Extra from 'https://www.7-zip.org/download.html'.${NL}" +
      "2. Extract all the contents of the archive into a directory '${PSScriptRoot}'.")
    }
  }

  # Specifying '7za.exe' parameters.
  $Params = @('a', "-t${P_Type}", "-mx${P_Level}", "${P_Out}", "${P_In}")

  # Running '7za.exe'.
  & "${7zExe}" $Params
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Start-Transcript -LiteralPath "${P_Logs}\$((Get-Date).Year)\$((Get-Date).Month)\${TS}.log"
Start-Script
Stop-Transcript
