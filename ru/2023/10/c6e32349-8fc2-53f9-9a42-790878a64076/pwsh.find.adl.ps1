function Find-AvailableDriveLetter() {
  (68..90 | ForEach-Object { $L=[char]$_; if ((Get-PSDrive).Name -notContains $L) { $L } })[0]
}
