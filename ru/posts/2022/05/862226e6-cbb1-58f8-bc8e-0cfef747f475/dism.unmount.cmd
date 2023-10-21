:: Automatic unmounting WIM images into DISM.
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

echo Unmounting "install.wim" and discards changes that were made when image was mounted...
Dism /Unmount-Image /MountDir:"%d_mnt%" /Discard

echo Deleting all of resources associated with a mounted image that has been corrupted...
Dism /Cleanup-Mountpoints

echo Getting information about mounted image...
Dism /Get-MountedImageInfo

exit /b 0
