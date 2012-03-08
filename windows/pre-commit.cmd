@ECHO OFF
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Original Publication: 2010/09/02 - Stackoverflow
:: Source:               https://github.com/philibertperusse/subversion-hooks
:: Author(s):            Philibert Perusse, ing., M.Sc.A. - http://philibertperusse.me
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Licensed under the Creative Commons Attribution 3.0 License - http://creativecommons.org/licenses/by/3.0/
::  - Free for use in both personal and commercial projects
::  - Attribution requires leaving author name, author link, and the license info intact.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: This is a pre-commit hook for subversion that ensures that your 
:: commits do not contain empty messages.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
setlocal

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Get subversion arguments
set repos=%~1
set txn=%2

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Set some variables
set svnlookparam="%repos%" -t %txn%

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Make sure that the new svn:log message contains some text.
set bIsEmpty=true
for /f "tokens=* usebackq" %%g in (`svnlook log %svnlookparam%`) do (
   set bIsEmpty=false
)
if '%bIsEmpty%'=='true' goto ERROR_EMPTY

echo Allowed. >&2

goto :END


:ERROR_EMPTY
echo Empty log messages are not allowed. >&2
goto ERROR_EXIT

:ERROR_EXIT
exit 1
:: exit /b 1 :: (for manual debugging and not closing CMD.EXE)

:END
endlocal
