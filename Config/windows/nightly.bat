SETLOCAL
@echo on

IF %1.==. ( echo "No arch" 
goto Fin )

::set EXIT_PROMPT=1
::logs are deleted by C:\dashboard\scripts\clean_otb_cron.bat 
::del C:\dashboard\logs\*.txt

set COMPILER_ARCH=%1

set CURRENT_SCRIPT_DIR=%~dp0

::always one. this is used to control ctest verbose option
:: we need ctest -VV when running locally/manually by called dashboard.bat
:: but we use ctest -V when run from taskscheduler aka taskschd
set FROM_TASKSCHD=1

::net use R: /delete /Y
::net use R: \\otbnas.si.c-s.fr\otbdata\otb /persistent:no

cmake -DCOMPILER_ARCH=%COMPILER_ARCH% -P %CURRENT_SCRIPT_DIR%nightly.cmake > C:\dashboard\logs\nightly_bat.txt 2>&1

goto Fin

:Fin
echo "called :Fin. End of nightly.bat script."
::net use R: /delete /Y
ENDLOCAL

::cmd /C start /wait %CURRENT_SCRIPT_DIR%\dashboard.bat %COMPILER_ARCH% 0 1 develop master
