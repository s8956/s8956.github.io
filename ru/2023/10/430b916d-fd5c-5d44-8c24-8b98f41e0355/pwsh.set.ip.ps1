<#PSScriptInfo
  .VERSION      0.1.0
  .GUID         b42524a4-c0d0-4402-951c-e97aa140698e
  .AUTHOR       Kai Kimera
  .AUTHOREMAIL  mail@kai.kim
  .COMPANYNAME  Library Online
  .COPYRIGHT    2023 Library Online. All rights reserved.
  .LICENSEURI   https://choosealicense.com/licenses/mit/
  .PROJECTURI   https://lib.onl/ru/articles/2023/10/430b916d-fd5c-5d44-8c24-8b98f41e0355/
#>

#Requires -Version 7.2
#Requires -RunAsAdministrator

# -------------------------------------------------------------------------------------------------------------------- #
# CONFIGURATION.
# -------------------------------------------------------------------------------------------------------------------- #

$Adapter = @{
  # Interface index.
  InterfaceIndex = 0
}

$IP = @{
  # IP address.
  IPAddress = '192.168.0.10'
  # Subnet mask.
  PrefixLength = '24'
  # Gateway.
  DefaultGateway = '192.168.0.1'
}

$DNS = @{
  # DNS servers.
  ServerAddresses = (
    '192.168.0.2',
    '192.168.1.2'
  )
}

# -------------------------------------------------------------------------------------------------------------------- #
# -------------------------------------------------< RUNNING SCRIPT >------------------------------------------------- #
# -------------------------------------------------------------------------------------------------------------------- #

Get-NetAdapter @Adapter | Remove-NetIPAddress -Confirm:$false   # Removing current IP address.
Get-NetAdapter @Adapter | Remove-NetRoute -Confirm:$false       # Removing current gateway.
Get-NetAdapter @Adapter | New-NetIPAddress @IP                  # Setting new IP address.
Get-NetAdapter @Adapter | Set-DNSClientServerAddress @DNS       # Setting new DNS servers.
