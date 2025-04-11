param(
  [Alias('P')][string]$Path,
  [Alias('T')][long]$Time
)

function Find-LastWriteTime() {
  Get-ChildItem -Path "${Path}" -Recurse -File
    | Sort-Object -Property 'LastAccessTime'
    | Where-Object { (($_.LastWriteTime) -lt ((Get-Date).AddSeconds(-$Time))) }
}

Find-LastWriteTime
