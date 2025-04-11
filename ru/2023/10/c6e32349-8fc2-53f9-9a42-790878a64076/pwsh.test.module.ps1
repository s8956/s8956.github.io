param(
  [Alias('N')][string[]]$Names,
  [Alias('A')][string]$Action = 'Stop'
)

function Test-Module() {
  ForEach ($Name in $Names) {
    if (-not (Get-Module -ListAvailable -Name "${Name}")) {
      Write-Error -Message "Module '${Name}' not installed!" -ErrorAction "${Action}"
    }
  }
}

Test-Module
