Param(
  [Alias('P')][string[]]$Path
)

function Set-EnvPathUser() {
  $Path | ForEach-Object {
    [Environment]::SetEnvironmentVariable(
      'Path', ([Environment]::GetEnvironmentVariables('User')).Path + "${_}" + [IO.Path]::PathSeparator, 'User'
    )
  }
}

Set-EnvPathUser
