@ECHO OFF
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Original Publication: 2006/03/02 - Subversion Mailing List
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
