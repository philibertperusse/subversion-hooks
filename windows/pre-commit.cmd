@ECHO OFF
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Original Publication: 2010/09/02 - Stackoverflow
:: Source:               https://github.com/philibertperusse/subversion-hooks
:: Author(s):            Philibert Perusse (http://philibertperusse.me)
::
:: Credits shall be kept in all version (modified or not) of this file.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Usage of this file follows the Free Software Definition 
:: (http://en.wikipedia.org/wiki/Free_Software_Definition):
::
::   Freedom 0: The freedom to run the program for any purpse.
::   Freedom 1: The freedom to study how the program works, and change 
::              it to make it do what you wish.
::   Freedom 2: The freedom to redistribute copies so you can help your 
::              neighbor.
::   Freedom 3: The freedom to improve the program, and release your 
::              improvements (and modified versions in general) to the 
::              public, so that the whole community benefits.
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
