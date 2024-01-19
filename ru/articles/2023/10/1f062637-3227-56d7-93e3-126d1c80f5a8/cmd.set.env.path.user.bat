:: Setting PATH variable for user.
::
:: @package   CMD
:: @author    Kai Kimera <mail@kai.kim>
:: @copyright 2023 Library Online
:: @license   MIT
:: @version   0.1.0
:: @link      https://lib.onl/ru/articles/2023/10/1f062637-3227-56d7-93e3-126d1c80f5a8/
:: ------------------------------------------------------------------------------------------------------------------ ::

@echo off
setLocal EnableDelayedExpansion

:: Custom PATH.
set "pathArray=C:\Apps\App_01 C:\Apps\App_02 C:\Apps\App_03"

:: Getting the current PATH variable.
for /f "tokens=2,*" %%a in ( 'reg query HKCU\Environment /v Path' ) do ( set "pathUser=%%b" )

:: Building a user PATH variable.
for %%p in ( %pathArray% ) do ( set "pathCustom=%%p;!pathCustom!" )

:: Setting a new PATH variable.
setx Path "!pathUser!!pathCustom!"
