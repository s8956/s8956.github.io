function Test-Module() {
  Param(
    [Alias('N')][string[]]$P_Names,
    [Alias('A')][string]$P_Action = 'Stop'
  )

  ForEach ($Name in $P_Names) {
    if (-not (Get-Module -ListAvailable -Name "${Name}")) {
      Write-Error -Message "Module '${Name}' not installed!" -ErrorAction "${P_Action}"
    }
  }
}
