:: Setting PATH variable for system.
::
:: @package   CMD
:: @author    z17CX <mail@z17.cx>
:: @copyright 2023 Library Online
:: @license   MIT
:: @version   0.1.0
:: @link      https://lib.onl/ru/articles/2023/10/1f062637-3227-56d7-93e3-126d1c80f5a8/
:: ------------------------------------------------------------------------------------------------------------------ ::

@echo off
setLocal EnableDelayedExpansion

:: Custom PATH.
set "pathArray=C:\Apps\App_01 C:\Apps\App_02 C:\Apps\App_03"

:: Building a system PATH variable.
for %%p in ( %pathArray% ) do ( set "pathCustom=%%p;!pathCustom!" )

:: Setting a new PATH variable.
setx /m Path "%Path%!pathCustom!"
