param(
  [Alias('F')][string]$File
)

function Compress-A7z() {
  Get-ChildItem "${File}" | ForEach-Object {
    & "$($Env:ProgramFiles)\7-Zip\7z.exe" a "$($_.FullName + '.7z')" "$($_.FullName)"
  }
}

Compress-A7z
