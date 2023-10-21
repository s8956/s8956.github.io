:: Automatic integration of updates into DISM.
::
:: @package   CMD
:: @author    Kitsune Solar <mail@kitsune.solar>
:: @copyright 2023 iHub TO
:: @license   MIT
:: @version   0.1.0
:: @link      https://lib.onl
:: ------------------------------------------------------------------------------------------------------------------ ::

@echo off

set d_mnt="%~dp0MNT"
set d_upd="%~dp0UPD"
set d_wim="%~dp0WIM"
set f_wim="%d_wim%\install.wim"

:: Creating directories.
if not exist "%d_mnt%" mkdir "%d_mnt%"
if not exist "%d_upd%" mkdir "%d_upd%"
if not exist "%d_wim%" mkdir "%d_wim%"

:: Checking files.
if not exist "%f_wim%" echo Please put "install.wim" file in "WIM" directory... && pause
if not exist "%d_upd%/*.msu" echo Please put "*.msu" files in "UPD" directory... && pause

if exist "%f_wim%" (
  echo Getting Windows Image Info...
  Dism /Get-ImageInfo /ImageFile:"%f_wim%"
) else (
  echo "install.wim" not found! & echo.Failed with error #%errorlevel%.
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
