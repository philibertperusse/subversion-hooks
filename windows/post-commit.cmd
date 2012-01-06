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
