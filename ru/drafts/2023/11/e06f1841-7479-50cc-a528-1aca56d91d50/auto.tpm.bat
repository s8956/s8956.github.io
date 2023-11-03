:: Bypassing system requirements checks (Windows 11).

reg add "HKLM\SOFTWARE\Microsoft\Windows\CurrentVersion\OOBE" /v "BypassNRO" /f /t "REG_DWORD" /d "1"
reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassCPUCheck" /f /t "REG_DWORD" /d "1"
reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassRAMCheck" /f /t "REG_DWORD" /d "1"
reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassSecureBootCheck" /f /t "REG_DWORD" /d "1"
reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassStorageCheck" /f /t "REG_DWORD" /d "1"
reg add "HKLM\SYSTEM\Setup\LabConfig" /v "BypassTPMCheck" /f /t "REG_DWORD" /d "1"
reg add "HKLM\SYSTEM\Setup\MoSetup" /v "AllowUpgradesWithUnsupportedTPMOrCPU" /f /t "REG_DWORD" /d "1"
