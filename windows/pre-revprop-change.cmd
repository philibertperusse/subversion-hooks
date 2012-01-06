::
@ECHO OFF
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Original Publication: 2006/03/02 - Subversion Mailing List
:: Source:               https://github.com/philibertperusse/subversion-hooks
:: Author(s):            Philibert Perusse (http://philibertperusse.me)
::
:: Credits shall be kept in all version (modified or not) of this file.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
::
:: Usage of this file follows the Free Software Definition 
:: (http://en.wikipedia.org/wiki/Free_Software_Definition):
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
:: This is a pre-revprop-change hook for subversion that allows editing 
:: commit messages of previous commits. In addition, it makes sure that
:: whatever new message is not empty.
::
:: You can derive a post-revprop-change hook from it to backup the old 
:: 'snv:log' somewhere if you wish to keep its history of changes.
::
:: The only tricky part in this batch file was to be able to actually 
:: parse the stdin from the batch file. This is done here with the 
:: native FIND.EXE command.
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::

set repos=%1
set rev=%2
set user=%3
set propname=%4
set action=%5

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Only allow changes to svn:log. The author, date and other revision
:: properties cannot be changed
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if /I not '%propname%'=='svn:log' goto ERROR_PROPNAME

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Only allow modifications to svn:log (no addition/overwrite or deletion)
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
if /I not '%action%'=='M' goto ERROR_ACTION

::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Make sure that the new svn:log message contains some text.
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
set bIsEmpty=true
for /f "tokens=*" %%g in ('find /V ""') do (
 set bIsEmpty=false
)
if '%bIsEmpty%'=='true' goto ERROR_EMPTY

goto :eof



:ERROR_EMPTY
echo Empty svn:log properties are not allowed. >&2
goto ERROR_EXIT

:ERROR_PROPNAME
echo Only changes to svn:log revision properties are allowed. >&2
goto ERROR_EXIT

:ERROR_ACTION
echo Only modifications to svn:log revision properties are allowed. >&2
goto ERROR_EXIT

:ERROR_EXIT
exit 1
:: exit /b 1 :: (for manual debugging and not closing CMD.EXE)
