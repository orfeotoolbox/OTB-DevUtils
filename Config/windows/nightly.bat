SETLOCAL
@echo on

IF %1.==. ( echo "No arch" 
goto Fin )

set EXIT_PROMPT=1

set COMPILER_ARCH=%1

set CURRENT_SCRIPT_DIR=%~dp0

net use R: /delete /Y
net use R: \\otbnas.si.c-s.fr\otbdata\otb /persistent:no

::set nightly_date=!date:~10,4!!date:~6,2!/!date:=~4,2!

set BUILD_START_DATE=%date:~-4%-%date:~4,2%-%date:~-7,2%

cmake -DCOMPILER_ARCH=%COMPILER_ARCH% -P %CURRENT_SCRIPT_DIR%nightly.cmake 

goto Fin

:Fin
echo "called :Fin. End of raoul.bat script."
net use R: /delete /Y
set BUILD_START_DATE=
ENDLOCAL

::cmd /C start /wait %CURRENT_SCRIPT_DIR%\dashboard.bat %COMPILER_ARCH% 0 1 develop master
