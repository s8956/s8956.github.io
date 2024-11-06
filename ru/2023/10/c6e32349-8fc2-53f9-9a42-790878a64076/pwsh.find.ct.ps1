param(
  [Alias('P')][string]$Path,
  [Alias('T')][long]$Time
)

function Find-CreationTime() {
  Get-ChildItem -Path "${Path}" -Recurse -File
    | Sort-Object -Property 'LastAccessTime'
    | Where-Object { (($_.CreationTime) -lt ((Get-Date).AddSeconds(-$Time))) }
}

Find-CreationTime
