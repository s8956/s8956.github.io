param(
  [Alias('F')][string]$File
)

function Compress-RAR() {
  Get-ChildItem "${File}" | ForEach-Object {
    & "$($Env:ProgramFiles)\WinRAR\Rar.exe" a "$($_.FullName + '.rar')" "$($_.FullName)"
  }
}

Compress-RAR
