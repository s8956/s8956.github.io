Param(
  [Alias('P')][string[]]$Path,
  [Parameter(Mandatory)][ValidateSet('Machine', 'User')][Alias('T')][string[]]$Target
)

function Set-EnvPath() {
  $Path | ForEach-Object {
    [Environment]::SetEnvironmentVariable(
      'Path', ([Environment]::GetEnvironmentVariables("${Target}")).Path + "${_}" + [IO.Path]::PathSeparator, "${Target}"
    )
  }
}

Set-EnvPath
