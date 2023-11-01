<#PSScriptInfo
  .VERSION      0.1.4
  .GUID         8fd0ce2c-0288-4d9c-805f-703a0c659ade
  .AUTHOR       Kitsune Solar
  .AUTHOREMAIL  mail@kitsune.solar
  .COMPANYNAME  iHub TO
  .COPYRIGHT    2023 iHub TO. All rights reserved.
  .LICENSEURI   https://choosealicense.com/licenses/mit/
  .PROJECTURI   https://lib.onl/ru/articles/2023/10/4c7aba7c-f5a6-589a-9975-fdb16f2e2862/
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
  .\pwsh.vault.ps1 -SRC 'C:\Data' -DST 'C:\Vault'

  .EXAMPLE
  .\pwsh.vault.ps1 -SRC 'C:\Data' -DST 'C:\Vault' -CT '864000' -WT '864000'

  .EXAMPLE
  .\pwsh.vault.ps1 -SRC 'C:\Data' -DST 'C:\Vault' -CT '864000' -WT '864000' -FS '32mb'

  .LINK
  https://lib.onl/ru/articles/2023/10/4c7aba7c-f5a6-589a-9975-fdb16f2e2862/
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
$TS = "$(Get-Date -Format 'yyyy-MM-dd.HH-mm-ss')"
$UTS = "$([DateTimeOffset]::Now.ToUnixTimeSeconds())"

# New line separator.
$NL = "$([Environment]::NewLine)"

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-Script() {
  Start-TestVault
  Start-MoveFiles
  if ($P_RemoveDirs) { Start-RemoveDirs }
}

# -------------------------------------------------------------------------------------------------------------------- #
# CREATING VAULT DIRECTORIES.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-TestVault() {
  $Dirs = @("${P_Source}", "${P_Vault}")
  $Files = @("${P_Exclude}")

  foreach ($Dir in $Dirs) {
    if (-not (Test-Data -T 'D' -P "${Dir}")) { New-Data -T 'D' -P "${Dir}" | Out-Null }
  }

  foreach ($File in $Files) {
    if (-not (Test-Data -T 'F' -P "${File}")) { New-Data -T 'F' -P "${File}" | Out-Null }
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# MOVING FILES TO VAULT.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-MoveFiles() {
  Write-Msg -T 'HL' -M 'Moving Files to Vault'

  $Files = ((Get-ChildItem -LiteralPath "${P_Source}" -Recurse -File -Exclude (Get-Content "${P_Exclude}"))
    | Where-Object { (($_.CreationTime) -lt ((Get-Date).AddSeconds(-$P_CreationTime))) `
      -and (($_.LastWriteTime) -lt ((Get-Date).AddSeconds(-$P_LastWriteTime))) }
    | Where-Object { ($_.Length) -ge "${P_FileSize}" })

  if (-not $Files) { Write-Msg -M "Required files were not found in the '${P_Source}'!" }

  $Files | ForEach-Object {
    $File = $_

    if (($File.FullName.Length) -ge 245) {
      Write-Msg -T 'W' -M "Over 250 characters in path! Skip:${NL}'${File}'"
      continue
    }

    $PathSRC = @("$($File.FullName)")
    $PathDST = @("$($File.FullName)", "$($File.DirectoryName)").ForEach({ $_.Remove(0, $P_Source.Length) })
    $PathDST[0] = (${P_Vault} | Join-Path -ChildPath "$($PathDST[0])")

    switch ($P_Mode) {
      'CP' {
        New-Data -T 'D' -P "${P_Vault}" -N "$($PathDST[1])" | Out-Null
        Compress-Data -P "$($PathDST[0])" -N "$($PathDST[0]).${UTS}.7z"

        Write-Msg -M "[CP] '$($PathSRC[0])' -> '$($PathDST[0])'"
        Copy-Data -S "$($PathSRC[0])" -D "$($PathDST[0])"
      }
      'MV' {
        New-Data -T 'D' -P "${P_Vault}" -N "$($PathDST[1])" | Out-Null
        Compress-Data -P "$($PathDST[0])" -N "$($PathDST[0]).${UTS}.7z"

        Write-Msg -M "[MV] '$($PathSRC[0])' -> '$($PathDST[0])'"
        Move-Data -S "$($PathSRC[0])" -D "$($PathDST[0])"
      }
      'RM' {
        Write-Msg -M "[RM] '$($PathSRC[0])'"
        Remove-Data -p "$($PathSRC[0])"
      }
    }
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# REMOVING EMPTY DIRECTORIES FROM SOURCE.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-RemoveDirs() {
  Write-Msg -T 'HL' -M 'Removing Empty Directories'

  do {
    $Dirs = ((Get-ChildItem -LiteralPath "${P_Source}" -Recurse -Directory)
      | Where-Object { (($_.CreationTime) -lt ((Get-Date).AddSeconds(-$P_CreationTime))) `
        -and (($_.LastWriteTime) -lt ((Get-Date).AddSeconds(-$P_LastWriteTime))) }
      | Where-Object { ((Get-ChildItem $_.FullName -Force).Count) -eq 0 }
      | Select-Object -ExpandProperty 'FullName')

    if (-not $Dirs) { Write-Msg -M "No empty directories were found in the '${P_Source}'!" }

    $Dirs | ForEach-Object {
      $Dir = $_
      Write-Msg -M "[RM] '${Dir}'"
      Remove-Data -P "${Dir}"
    }
  } while ( $Dirs.Count -gt 0 )
}

# -------------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------< COMMON FUNCTIONS >------------------------------------------------ #
# -------------------------------------------------------------------------------------------------------------------- #

# -------------------------------------------------------------------------------------------------------------------- #
# WORKING WITH ELEMENTS.
# -------------------------------------------------------------------------------------------------------------------- #

function Test-Data() {
  param (
    [Alias('T')][string]$Type,
    [Alias('P')][string]$Path
  )

  switch ($Type) {
    'D' { $Type = 'Container' }
    'F' { $Type = 'Leaf' }
  }

  Test-Path -LiteralPath "${Path}" -PathType "${Type}"
}

function New-Data() {
  param (
    [Alias('T')][string]$Type,
    [Alias('P')][string]$Path,
    [Alias('N')][string]$Name,
    [Alias('A')][string]$Action = 'SilentlyContinue'
  )

  switch ($Type) {
    'D' { $Type = 'Directory' }
    'F' { $Type = 'File' }
  }

  New-Item -Path "${Path}" -Name "${Name}" -ItemType "${Type}" -ErrorAction "${Action}"
}

function Copy-Data() {
  param (
    [Alias('S')][string]$Src,
    [Alias('D')][string]$Dst
  )

  Copy-Item -LiteralPath "${Src}" -Destination "${Dst}" -Force
}

function Move-Data() {
  param (
    [Alias('S')][string]$Src,
    [Alias('D')][string]$Dst
  )

  Move-Item -LiteralPath "${Src}" -Destination "${Dst}" -Force
}

function Remove-Data() {
  param (
    [Alias('P')][string]$Path
  )

  Remove-Item -LiteralPath "${Path}" -Force
}

function Compress-Data() {
  param (
    [Alias('P')][string]$Path,
    [Alias('N')][string]$Name
  )

  if (-not $P_Overwrite -and (Test-Data -T 'F' -P "${Path}")) {
    Start-7z -T '7z' -L 9 -I "${Path}" -O "${Name}"
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# SYSTEM MESSAGES.
# -------------------------------------------------------------------------------------------------------------------- #

function Write-Msg() {
  param (
    [Alias('T')][string]$Type,
    [Alias('M')][string]$Message,
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
# APP: 7-ZIP.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-7z() {
  param (
    [Alias('I')][string]$In,
    [Alias('O')][string]$Out,
    [ValidateSet('7z', 'BZIP2', 'GZIP', 'TAR', 'WIM', 'XZ', 'ZIP')][Alias('T')][string]$Type = '7z',
    [ValidateRange(1,9)][Alias('L')][int]$Level = 5
  )

  # File list for '7za.exe'.
  $7z = @('7za.exe', '7za.dll', '7zxa.dll')

  # Search '7za.exe'.
  $7zExe = ((Get-ChildItem -LiteralPath "${PSScriptRoot}" -Filter "$($7z[0])" -Recurse -File) | Select-Object -First 1)

  # Getting '7za.exe' directory.
  $7zDir = "$($7zExe.DirectoryName)"

  # Checking the location of files.
  foreach ($File in $7z) {
    if (-not (Test-Data -T 'F' -P "${7zDir}\${File}")) {
      Write-Msg -T 'W' -A 'Stop' -M ("'${File}' not found!${NL}${NL}" +
      "1. Download 7-Zip Extra from 'https://www.7-zip.org/download.html'.${NL}" +
      "2. Extract all the contents of the archive into a directory '${PSScriptRoot}'.")
    }
  }

  # Specifying '7za.exe' parameters.
  $Params = @('a', "-t${Type}", "-mx${Level}", "${Out}", "${In}")

  # Running '7za.exe'.
  & "${7zExe}" $Params
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Start-Transcript -LiteralPath "${P_Logs}\$((Get-Date).Year)\$((Get-Date).Month)\${TS}.log"
Start-Script
Stop-Transcript
