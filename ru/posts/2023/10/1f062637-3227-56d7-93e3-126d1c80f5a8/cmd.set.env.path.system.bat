@echo off
setLocal EnableDelayedExpansion

:: Custom "Path" parameters.
set "pathArray=C:\Apps\App_01 C:\Apps\App_02 C:\Apps\App_03"

:: Building custom "Path" variable.
for %%p in ( %pathArray% ) do ( set "pathCustom=%%p;!pathCustom!" )

:: Setting user new "Path" variable.
setx /m Path "%Path%!pathCustom!"
