param(
  [Alias('F')][string]$File
)

function Expand-RAR() {
  Get-ChildItem "${File}" | ForEach-Object {
    & "$($Env:ProgramFiles)\WinRAR\Rar.exe" x "$($_.FullName)"
  }
}

Expand-RAR
