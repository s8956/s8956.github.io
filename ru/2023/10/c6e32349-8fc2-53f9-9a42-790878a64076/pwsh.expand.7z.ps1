param(
  [Alias('F')][string]$File
)

function Expand-A7z() {
  Get-ChildItem "${File}" | ForEach-Object {
    & "$($Env:ProgramFiles)\7-Zip\7z.exe" x "$($_.FullName)"
  }
}

Expand-A7z
