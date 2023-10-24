function Find-LastWriteTime() {
  Param(
    [Alias('P')][string]$P_Path,
    [Alias('T')][long]$P_Time
  )

  Get-ChildItem -Path "${P_Path}" -Recurse -File
    | Sort-Object -Property 'LastAccessTime'
    | Where-Object { ($_.LastWriteTime -lt (Get-Date).AddSeconds(-$P_Time)) }
}
