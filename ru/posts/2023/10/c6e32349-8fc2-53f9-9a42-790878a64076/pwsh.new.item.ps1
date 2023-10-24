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
