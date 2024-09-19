<#PSScriptInfo
.VERSION      0.1.0
.GUID         18c25998-a474-425e-a59f-e32f79c8431d
.AUTHOR       Kai Kimera
.AUTHOREMAIL  mail@kai.kim
.COMPANYNAME  Library Online
.COPYRIGHT    2024 Library Online. All rights reserved.
.TAGS         windows server backup mail
.LICENSEURI   https://choosealicense.com/licenses/mit/
.PROJECTURI   https://lib.onl/ru/2024/09/40539e36-4656-5532-b920-8975c97d4dc5/
#>

<#
.SYNOPSIS
Script for sending messages about backup status.

.DESCRIPTION
The script sends messages to the specified address for further analysis.
The messages contain the host ID and notification type.

.EXAMPLE
.\app.backup.wsb.mail.ps1 -Type 'error' [-SSL]
.\app.backup.wsb.mail.ps1 -Type 'success' [-SSL]

.LINK
https://lib.onl/ru/2024/09/40539e36-4656-5532-b920-8975c97d4dc5/
#>

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION
# -------------------------------------------------------------------------------------------------------------------- #

Param(
  [Parameter(HelpMessage='Message type.')]
  [ValidateSet('error', 'success')]
  [string]$Type,
  [Parameter(HelpMessage='Enable or disable encrypted connection.')]
  [switch]$SSL = $false,
  [Alias('Host')][string]$Hostname = ([System.Net.Dns]::GetHostByName([string]'localhost').HostName)
)

# Loading configuration data.
$S = ((Get-Item "${PSCommandPath}").Basename + '.ini')
$P = (Get-Content -Path "${PSScriptRoot}\${S}" | ConvertFrom-StringData)

# Generating HostID (HID).
$UUID = (Get-CimInstance 'Win32_ComputerSystemProduct' | Select-Object -ExpandProperty 'UUID')
$HID = ((${Hostname} + ':' + ${UUID}).ToUpper())

# -------------------------------------------------------------------------------------------------------------------- #
# INITIALIZATION
# -------------------------------------------------------------------------------------------------------------------- #

function Start-Script() {
  switch ("${Type}") {
    'error'   { Send-BackupError }
    'success' { Send-BackupSuccess }
    default   { exit }
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# BACKUP: ERROR
# Sending an email after a failed backup.
# -------------------------------------------------------------------------------------------------------------------- #

function Send-BackupError() {
  $Subject = "Windows Server Backup: ${Hostname}"
  $Body = @"
Windows Server Backup failed: ${Hostname}.
Please check server backup!

Host: ${Hostname}
Status: ERROR

-- 
#ID:${HID}
#TYPE:BACKUP:ERROR
"@

  Start-Smtp -S "${Subject}" -B "${Body}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# BACKUP: SUCCESS
# Sending an email after a successful backup.
# -------------------------------------------------------------------------------------------------------------------- #

function Send-BackupSuccess() {
  $Subject = "Windows Server Backup: ${Hostname}"
  $Body = @"
Windows Server Backup completed successfully!

Host: ${Hostname}
Status: SUCCESS

-- 
#ID:${HID}
#TYPE:BACKUP:SUCCESS
"@

  Start-Smtp -S "${Subject}" -B "${Body}"
}

# -------------------------------------------------------------------------------------------------------------------- #
# SMTP
# SMTP configuration.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-Smtp {
  Param(
    [Alias('S')][string]$Subject,
    [Alias('B')][string]$Body
  )

  $SmtpClient = New-Object Net.Mail.SmtpClient("$($P.Server)", "$($P.Port)")
  $SmtpClient.EnableSsl = $SSL
  $SmtpClient.Credentials = New-Object System.Net.NetworkCredential("$($P.User)", "$($P.Password)")
  $SmtpClient.Send("$($P.From)", "$($P.To)", "${Subject}", "${Body}")
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Start-Script
