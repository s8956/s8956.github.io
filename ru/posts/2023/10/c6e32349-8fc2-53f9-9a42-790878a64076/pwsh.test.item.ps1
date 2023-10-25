param (
  [Alias('T')][string]$Type,
  [Alias('P')][string]$Path
)

function Test-Data() {
  switch ($Type) {
    'D' { $Type = 'Container' }
    'F' { $Type = 'Leaf' }
  }

  Test-Path -LiteralPath "${Path}" -PathType "${Type}"
}

Test-Data
