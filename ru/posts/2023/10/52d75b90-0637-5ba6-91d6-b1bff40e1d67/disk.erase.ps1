<#PSScriptInfo
  .VERSION      0.1.0
  .GUID         8d95f4d5-4d14-412c-9fa4-b75ebe79df09
  .AUTHOR       Kitsune Solar
  .AUTHOREMAIL  mail@kitsune.solar
  .COMPANYNAME  iHub TO
  .COPYRIGHT    2023 iHub TO. All rights reserved.
  .LICENSEURI   https://choosealicense.com/licenses/mit/
  .PROJECTURI   https://lib.onl/ru/posts/2023/10/52d75b90-0637-5ba6-91d6-b1bff40e1d67/
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

  .PARAMETER P_DriveLetter
  Specifies the specific drive letter to assign to the new partition.

  .PARAMETER P_FileSystem
  Specifies the file system with which to format the volume.
  The acceptable values for this parameter are: 'NTFS', 'ReFS', 'exFAT', 'FAT32' and 'FAT'.

  .PARAMETER P_FileSystemLabel
  Specifies the label to use for the volume.

  .PARAMETER P_Sleep
  Sleep time (in seconds).

  .EXAMPLE
  .\disk.erase.ps1 -DN 3 -DL 'E' -FS 'NTFS' -FSL 'USB-SSD'

  .LINK
  https://lib.onl/ru/posts/2023/10/52d75b90-0637-5ba6-91d6-b1bff40e1d67/
#>

Param(
  [Parameter(HelpMessage="Specify the disk number.")]
  [ValidatePattern('^[0-9]+$')]
  [Alias('DN')][int]$P_DiskNumber,

  [Parameter(HelpMessage="Specify the drive letter to assign to the new partition.")]
  [ValidatePattern('^[A-Z]$')]
  [Alias('DL')][string]$P_DriveLetter,

  [Parameter(HelpMessage="Specify the file system to format the volume.")]
  [ValidateSet('FAT', 'FAT32', 'exFAT', 'NTFS', 'ReFS')]
  [Alias('FS')][string]$P_FileSystem,

  [Parameter(HelpMessage="Specify a new label to use for the volume.")]
  [Alias('FSL')][string]$P_FileSystemLabel,

  [Parameter(HelpMessage="Sleep time (in seconds).")]
  [Alias('S')][int]$P_Sleep = 2
)

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION.
# -------------------------------------------------------------------------------------------------------------------- #

# New line separator.
$NL = [Environment]::NewLine

# Random number.
$Random = "$(Get-Random -Minimum 1000 -Maximum 9999)"

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-Script() {
  Start-DPDiskList

  # Get params.
  if (-not $P_DiskNumber) { $P_DiskNumber = (Read-Host -Prompt 'Disk number') }
  if (-not $P_DriveLetter) { $P_DriveLetter = (Read-Host -Prompt 'Drive letter') }
  if (-not $P_FileSystem) { $P_FileSystem = (Read-Host -Prompt 'File system') }
  if (-not $P_FileSystemLabel) { $P_FileSystemLabel = (Read-Host -Prompt 'New volume label') }

  Start-DPDiskClear
  Start-DPDiskInit
  Start-DPDiskPartition
  Start-DPDiskFormat
}

# -------------------------------------------------------------------------------------------------------------------- #
# DISK LIST.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-DPDiskList() {
  Show-DPDiskList
  Start-Sleep -s $P_Sleep
}

# -------------------------------------------------------------------------------------------------------------------- #
# CLEAR DISK.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-DPDiskClear() {
  Write-Msg -T 'HL' -M "[DISK ${P_DiskNumber}] Clear Disk..."
  Write-Msg -T 'W' -A 'Inquire' -M ("You specified drive number '${P_DiskNumber}'.${NL}" +
  "All data will be DELETED!")
  Clear-Disk -Number $P_DiskNumber -RemoveData -RemoveOEM -Confirm:$false
  Show-DPDiskList
  Start-Sleep -s $P_Sleep
}

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZE DISK.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-DPDiskInit() {
  Write-Msg -T 'HL' -M "[DISK ${P_DiskNumber}] Initialize Disk..."
  Initialize-Disk -Number $P_DiskNumber -PartitionStyle 'GPT'
  Show-DPDiskList
  Start-Sleep -s $P_Sleep
}

# -------------------------------------------------------------------------------------------------------------------- #
# CREATE PARTITION.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-DPDiskPartition() {
  Write-Msg -T 'HL' -M "[DISK ${P_DiskNumber}] Create Partition..."
  New-Partition -DiskNumber $P_DiskNumber -UseMaximumSize -DriveLetter "${P_DriveLetter}"
  Start-Sleep -s $P_Sleep
}

# -------------------------------------------------------------------------------------------------------------------- #
# FORMAT DISK VOLUME.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-DPDiskFormat() {
  Write-Msg -T 'HL' -M "[DISK ${P_DiskNumber}] Format Disk Volume (${P_DriveLetter} / ${P_FileSystem})..."
  if (-not $P_FileSystemLabel) { $P_FileSystemLabel = "DISK_${Random}" }
  Format-Volume -DriveLetter "${P_DriveLetter}" -FileSystem "${P_FileSystem}" -Force -NewFileSystemLabel "${P_FileSystemLabel}"
  Show-DPVolumeList
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
# DISK LIST.
# -------------------------------------------------------------------------------------------------------------------- #

function Show-DPDiskList() {
  Write-Msg -T 'HL' -M "[DISK ${P_DiskNumber}] Disk List..."
  Get-Disk
}

# -------------------------------------------------------------------------------------------------------------------- #
# VOLUME LIST.
# -------------------------------------------------------------------------------------------------------------------- #

function Show-DPVolumeList() {
  Write-Msg -T 'HL' -M "[DISK ${P_DiskNumber}] Volume List..."
  Get-Volume
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Start-Script
