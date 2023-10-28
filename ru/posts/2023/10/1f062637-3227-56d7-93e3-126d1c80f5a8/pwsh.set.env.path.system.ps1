Param(
  [Alias('P')][string[]]$Path
)

function Set-EnvPathSystem() {
  $Path | ForEach-Object {
    [Environment]::SetEnvironmentVariable(
      'Path', ([Environment]::GetEnvironmentVariables('Machine')).Path + "${_}" + [IO.Path]::PathSeparator, 'Machine'
    )
  }
}

Set-EnvPathSystem
