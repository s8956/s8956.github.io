@echo off
setLocal EnableDelayedExpansion

:: Custom "Path" parameters.
set "pathArray=C:\Apps\App_01 C:\Apps\App_02 C:\Apps\App_03"

:: Getting user current "Path" variable.
for /f "tokens=2,*" %%a in ( 'reg query HKCU\Environment /v Path' ) do ( set "pathUser=%%b" )

:: Building custom "Path" variable.
for %%p in ( %pathArray% ) do ( set "pathCustom=%%p;!pathCustom!" )

:: Setting user new "Path" variable.
setx Path "!pathUser!!pathCustom!"
