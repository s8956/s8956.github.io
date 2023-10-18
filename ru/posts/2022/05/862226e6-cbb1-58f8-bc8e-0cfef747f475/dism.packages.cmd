:: Automatic integration of updates into DISM.
::
:: @package   CMD
:: @author    Kitsune Solar <mail@kitsune.solar>
:: @copyright 2023 iHub TO
:: @license   MIT
:: @version   0.0.1
:: @link      https://lib.onl
:: ------------------------------------------------------------------------------------------------------------------ ::

@echo off

if exist "%~dp0WIM\install.wim" (
  echo Getting Windows Image Info...
  Dism /Get-ImageInfo /ImageFile:"%~dp0WIM\install.wim"
) else (
  echo 'install.wim' not found! & echo.Failed with error #%errorlevel%.
  goto :error
)

set /p index="Enter INDEX: "

echo Mounting Windows image...
Dism /Mount-Image /ImageFile:"%~dp0WIM\install.wim" /MountDir:"%~dp0MNT" /index:%index%

echo Adding Windows packages...
Dism /Image:"%~dp0MNT" /Add-Package /PackagePath:"%~dp0UPD"

echo Getting Windows packages...
Dism /Image:"%~dp0MNT" /Get-Packages

echo Reseting Windows image...
Dism /Image:"%~dp0MNT" /Cleanup-Image /StartComponentCleanup /ResetBase

echo Scaning health Windows image...
Dism /Image:"%~dp0MNT" /Cleanup-Image /ScanHealth

echo Saving Windows image...
Dism /Unmount-Image /MountDir:"%~dp0MNT" /Commit

exit /b 0

:error
exit /b %errorlevel%
