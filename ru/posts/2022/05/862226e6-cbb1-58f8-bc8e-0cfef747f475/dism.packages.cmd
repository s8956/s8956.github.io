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

set f_wim="%~dp0WIM\install.wim"
set d_mnt="%~dp0MNT"
set d_upd="%~dp0UPD"

if exist "%f_wim%" (
  echo Getting Windows Image Info...
  Dism /Get-ImageInfo /ImageFile:"%f_wim%"
) else (
  echo 'install.wim' not found! & echo.Failed with error #%errorlevel%.
  goto :error
)

set /p index="Enter INDEX: "

echo Mounting Windows image...
Dism /Mount-Image /ImageFile:"%f_wim%" /MountDir:"%d_mnt%" /index:%index%

echo Adding Windows packages...
Dism /Image:"%d_mnt%" /Add-Package /PackagePath:"%d_upd%"

echo Getting Windows packages...
Dism /Image:"%d_mnt%" /Get-Packages

echo Reseting Windows image...
Dism /Image:"%d_mnt%" /Cleanup-Image /StartComponentCleanup /ResetBase

echo Scaning health Windows image...
Dism /Image:"%d_mnt%" /Cleanup-Image /ScanHealth

echo Saving Windows image...
Dism /Unmount-Image /MountDir:"%d_mnt%" /Commit

exit /b 0

:error
exit /b %errorlevel%
