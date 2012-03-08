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
:: This is a post-commit hook for subversion that sends an email 
:: notification that something changed in the repository to a list of 
:: email addresses.
:: 
:: You need sendmail.exe (http://glob.com.au/sendmail/) in the same folder 
:: than your hook file, along with sendmail.ini.
::
:: You also need a file post-commit.tos.txt next to your hook file to 
:: list the mail recipients. The file should contain:
::  user1@example.com,user2@example.com,user3@example.com
::
::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::::
setlocal

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Get subversion arguments
set repos=%~1
set rev=%2

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Set some variables
set tos=%repos%\hooks\%~n0.tos.txt
set reposname=%~nx1
set svnlookparam="%repos%" --revision %rev%

if not exist "%tos%" goto :END

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Prepare sendmail email file
set author=
for /f "tokens=* usebackq" %%g in (`svnlook author %svnlookparam%`) do (
  set author=%%g
)

for /f "tokens=* usebackq delims=" %%g in ("%tos%") do (
  set EmailNotificationTo=%%g
)
set SendMailFile=%~n0_%reposname%_%rev%.sm

echo To: %EmailNotificationTo% >> "%SendMailFile%"
echo From: %reposname%.svn.technologie@gsmprjct.com >> "%SendMailFile%"
echo Subject: [%reposname%] Revision %rev% - Subversion Commit Notification  >> "%SendMailFile%"

echo --- log [%author%] --- >> "%SendMailFile%"
svnlook log %svnlookparam% >> "%SendMailFile%" 2>&1
echo --- changed --- >> "%SendMailFile%"
svnlook changed %svnlookparam% --copy-info >> "%SendMailFile%" 2>&1

echo .>> "%SendMailFile%"

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Send email
type "%SendMailFile%" | "%~dp0sendmail.exe" -t

:::::::::::::::::::::::::::::::::::::::::::::::::::::::::
:: Clean-up
if exist "%SendMailFile%" del "%SendMailFile%"


:END
endlocal
