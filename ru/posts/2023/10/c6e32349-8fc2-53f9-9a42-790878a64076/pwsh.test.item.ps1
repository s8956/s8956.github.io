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
