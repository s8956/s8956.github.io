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
