rem # Setting PATH variable for user.
rem #
rem # @package   CMD
rem # @author    Kai Kimera <mail@kai.kim>
rem # @copyright 2023 Library Online
rem # @license   MIT
rem # @version   0.1.0
rem # @link      https://lib.onl/ru/articles/2023/10/1f062637-3227-56d7-93e3-126d1c80f5a8/
rem # ---------------------------------------------------------------------------------------------------------------- #

@echo off
setLocal EnableDelayedExpansion

rem Custom PATH.
set "pathArray=C:\Apps\App_01 C:\Apps\App_02 C:\Apps\App_03"

rem Getting the current PATH variable.
for /f "tokens=2,*" %%a in ( 'reg query HKCU\Environment /v Path' ) do ( set "pathUser=%%b" )

rem Building a user PATH variable.
for %%p in ( %pathArray% ) do ( set "pathCustom=%%p;!pathCustom!" )

rem Setting a new PATH variable.
setx Path "!pathUser!!pathCustom!"
