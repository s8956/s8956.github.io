param(
  [Alias('F')][string]$File
)

function Get-FileSize() {
  (Get-Item "${File}").Length      # Size in bytes.
  (Get-Item "${File}").Length/1KB  # Size in KB.
  (Get-Item "${File}").Length/1MB  # Size in MB.
  (Get-Item "${File}").Length/1GB  # Size in GB.
  (Get-Item "${File}").Length/1TB  # Size in TB.
}

Get-FileSize
