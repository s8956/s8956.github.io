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
