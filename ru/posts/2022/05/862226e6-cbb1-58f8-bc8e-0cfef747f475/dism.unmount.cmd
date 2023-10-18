:: Automatic unmounting WIM images into DISM.
::
:: @package   CMD
:: @author    Kitsune Solar <mail@kitsune.solar>
:: @copyright 2023 iHub TO
:: @license   MIT
:: @version   0.0.1
:: @link      https://lib.onl
:: ------------------------------------------------------------------------------------------------------------------ ::

@echo off

echo Unmounting 'install.wim' and discards changes that were made when image was mounted...
Dism /Unmount-Image /MountDir:"%~dp0MNT" /Discard

echo Deleting all of resources associated with a mounted image that has been corrupted...
Dism /Cleanup-Mountpoints

echo Getting information about mounted image...
Dism /Get-MountedImageInfo

exit /b 0
