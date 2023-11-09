<#PSScriptInfo
  .VERSION      0.1.0
  .GUID         8d95f4d5-4d14-412c-9fa4-b75ebe79df09
  .AUTHOR       Kitsune Solar
  .AUTHOREMAIL  mail@kitsune.solar
  .COMPANYNAME  Library Online
  .COPYRIGHT    2023 Library Online. All rights reserved.
  .LICENSEURI   https://choosealicense.com/licenses/mit/
  .PROJECTURI   https://lib.onl/ru/articles/2023/10/52d75b90-0637-5ba6-91d6-b1bff40e1d67/
#>

#Requires -Version 7.2
#Requires -RunAsAdministrator

<#
  .SYNOPSIS
  Disk erase script.

  .DESCRIPTION
  Disk cleanup followed by partition creation.

  .PARAMETER P_DiskNumber
  Specifies the disk number of the disk on which to perform the clear operation. For a list of available disks, see the 'Get-Disk' cmdlet.

  .PARAMETER P_FileSystem
  Specifies the file system with which to format the volume.
  The acceptable values for this parameter are: 'NTFS', 'ReFS', 'exFAT', 'FAT32' and 'FAT'.

  .PARAMETER P_Sleep
  Sleep time (in seconds).

  .EXAMPLE
  .\pwsh.disk.erase.ps1 -DN 3 -DL 'E' -FS 'NTFS' -FSL 'USB-SSD'

  .LINK
  https://lib.onl/ru/articles/2023/10/52d75b90-0637-5ba6-91d6-b1bff40e1d67/
#>

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION.
# -------------------------------------------------------------------------------------------------------------------- #

Param(
  [Parameter(HelpMessage="Specify the disk number.")]
  [ValidatePattern('^[0-9]+$')]
  [Alias('DN')][int]$P_DiskNumber,

  [Parameter(HelpMessage="Specify the file system to format the volume.")]
  [ValidateSet('FAT', 'FAT32', 'exFAT', 'NTFS', 'ReFS')]
  [Alias('FS')][string]$P_FileSystem,

  [Parameter(HelpMessage="Sleep time (in seconds).")]
  [Alias('S')][int]$P_Sleep = 2
)

# New line separator.
$NL = "$([Environment]::NewLine)"

# Random number.
$Random = "$(Get-Random -Minimum 1000 -Maximum 9999)"

# Getting free drive letter and to assign to the new partition.
$DriveLetter = "$((68..90 | ForEach-Object { $L=[char]$_; if ((Get-PSDrive).Name -notContains $L) { $L } })[0])"

# Specifying a new label to use for the volume.
$FileSystemLabel = "DISK_${Random}"

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-Script() {
  Start-DPDiskList        # Showing disk list.
  if (-not $P_DiskNumber) { $P_DiskNumber = (Read-Host -Prompt 'Disk number') }   # Getting disk number.
  if (-not $P_FileSystem) { $P_FileSystem = (Read-Host -Prompt 'File system') }   # Getting file system.
  Start-DPDiskClear       # Starting clearing disk.
  Start-DPDiskInit        # Initializing disk.
  Start-DPDiskPartition   # Creating partition.
  Start-DPDiskFormat      # Formatting volume.
}

# -------------------------------------------------------------------------------------------------------------------- #
# DISK LIST.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-DPDiskList() {
  Write-Msg -T 'HL' -M 'Disk List'
  Get-Disk
}

# -------------------------------------------------------------------------------------------------------------------- #
# CLEAR DISK.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-DPDiskClear() {
  Write-Msg -T 'HL' -M "[DISK #${P_DiskNumber}] Clear Disk"
  Write-Msg -T 'W' -A 'Inquire' -M ("You specified drive number '${P_DiskNumber}'.${NL}" +
  "All data will be DELETED!")

  $Param = @{
    Number = $P_DiskNumber
    RemoveData = $true
    RemoveOEM = $true
    Confirm = $false
  }

  Clear-Disk @Param
  Start-Sleep -s $P_Sleep
}

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZE DISK.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-DPDiskInit() {
  Write-Msg -T 'HL' -M "[DISK #${P_DiskNumber}] Initialize Disk"

  $Param = @{
    Number = $P_DiskNumber
    PartitionStyle = 'GPT'
  }

  Initialize-Disk @Param
  Start-Sleep -s $P_Sleep
}

# -------------------------------------------------------------------------------------------------------------------- #
# CREATE PARTITION.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-DPDiskPartition() {
  Write-Msg -T 'HL' -M "[DISK #${P_DiskNumber}] Create Partition"

  $Param = @{
    DiskNumber = $P_DiskNumber
    DriveLetter = "${DriveLetter}"
    UseMaximumSize = $true
  }

  New-Partition @Param
  Start-Sleep -s $P_Sleep
}

# -------------------------------------------------------------------------------------------------------------------- #
# FORMAT DISK VOLUME.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-DPDiskFormat() {
  Write-Msg -T 'HL' -M "[DISK #${P_DiskNumber}] Format Disk Volume (${DriveLetter} / ${P_FileSystem})"

  if (-not $P_FileSystem) { $P_FileSystem = 'NTFS' }

  $Param = @{
    DriveLetter = "${DriveLetter}"
    FileSystem = "${P_FileSystem}"
    NewFileSystemLabel = "${FileSystemLabel}"
    Force = $true
  }

  Format-Volume @Param
  Start-Sleep -s $P_Sleep
}

# -------------------------------------------------------------------------------------------------------------------- #
# ------------------------------------------------< COMMON FUNCTIONS >------------------------------------------------ #
# -------------------------------------------------------------------------------------------------------------------- #

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
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Start-Script
