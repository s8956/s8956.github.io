<#PSScriptInfo
.VERSION      0.1.0
.GUID         fc37f35a-a9b7-43ed-8316-9520cbae9622
.AUTHOR       koolance / Kai Kimera
.AUTHOREMAIL  mail@kai.kim
.COMPANYNAME  Library Online
.COPYRIGHT    2024 Library Online. All rights reserved.
.TAGS         windows veritas backup exec
.LICENSEURI   https://choosealicense.com/licenses/mit/
.PROJECTURI   https://lib.onl/ru/2025/03/0e079d06-d87d-50de-b8e2-713a8ddb8fd6/
#>

<#
.SYNOPSIS
Script to extend the trial period of Veritas Backup Exec.

.DESCRIPTION
The script allows you to extend the trial period of Veritas Backup Exec by adjusting the Windows registry.

.EXAMPLE
.\app.be.trial.ps1 -Version '23.0'

.LINK
https://lib.onl/ru/2025/03/0e079d06-d87d-50de-b8e2-713a8ddb8fd6/
#>

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION
# -------------------------------------------------------------------------------------------------------------------- #

param(
  [Parameter(HelpMessage='Installed version of Backup Exec.')]
  [Alias('V')][string]$Version = '23.0'
)

$Path = "HKLM:\Software\Veritas\Backup Exec For Windows\Common\Backup Exec\${Version}"
$ObjName = 'SD'

# -------------------------------------------------------------------------------------------------------------------- #
# TRIAL EXTENSION
# Extending the trial period.
# -------------------------------------------------------------------------------------------------------------------- #

function Start-TrialExt() {
  $GetObj = Get-ItemProperty -Path "${Path}" -Name "${ObjName}"

  if ($null -ne $GetObj.SD -and $GetObj.SD.Count -gt 678) {
    # Year.
    $GetObj.SD[660] = 0x32
    $GetObj.SD[662] = 0x30
    $GetObj.SD[664] = 0x35
    $GetObj.SD[666] = 0x30
    # Month.
    $GetObj.SD[670] = 0x30
    $GetObj.SD[672] = 0x31
    # Day.
    $GetObj.SD[676] = 0x30
    $GetObj.SD[678] = 0x32
    $ObjValue = $GetObj.SD

    try {
      New-ItemProperty -Path "${Path}" -Name 'SD_bak' -PropertyType 'Binary' -Value $ObjValue -ErrorAction 'Stop'
    } catch [System.IO.IOException] {
      Set-ItemProperty -Path "${Path}" -Name 'SD_bak' -Value $ObjValue
    }

    Set-ItemProperty -Path "${Path}" -Name "${ObjName}" -Value $ObjValue
  } else {
    Write-Error 'The SD array does not exist or is not long enough.'
  }
}

# -------------------------------------------------------------------------------------------------------------------- #
# MAIN
# -------------------------------------------------------------------------------------------------------------------- #

function Start-Main() {
  Start-TrialExt
}; Start-Main
