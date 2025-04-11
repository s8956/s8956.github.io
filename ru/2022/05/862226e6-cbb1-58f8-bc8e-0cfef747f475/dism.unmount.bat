rem # Automatic unmounting WIM images into DISM.
rem #
rem # @package   CMD
rem # @author    Kai Kimera <mail@kai.kim>
rem # @copyright 2023 Library Online
rem # @license   MIT
rem # @version   0.1.0
rem # @link      https://lib.onl/ru/2022/05/862226e6-cbb1-58f8-bc8e-0cfef747f475/
rem # ---------------------------------------------------------------------------------------------------------------- #

@echo off
set d_mnt="%~dp0MNT"

echo Unmounting "install.wim" and discards changes that were made when image was mounted...
Dism /Unmount-Image /MountDir:"%d_mnt%" /Discard

echo Deleting all of resources associated with a mounted image that has been corrupted...
Dism /Cleanup-Mountpoints

echo Getting information about mounted image...
Dism /Get-MountedImageInfo

exit /b 0
