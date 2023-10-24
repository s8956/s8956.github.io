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
