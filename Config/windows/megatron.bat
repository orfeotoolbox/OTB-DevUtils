SETLOCAL
@echo on

IF %1.==. ( echo "No arch" 
goto Fin )

set COMPILER_ARCH=%1

set CURRENT_SCRIPT_DIR=%~dp0

net use R: /delete /Y
net use R: \\otbnas.si.c-s.fr\otbdata\otb /persistent:no

cmake -DCOMPILER_ARCH=%COMPILER_ARCH% -P %CURRENT_SCRIPT_DIR%\megatron.cmake 

goto Fin

:Fin
echo "called :Fin. End of megatron.bat script."
net use R: /delete /Y
ENDLOCAL

::cmd /C start /wait %CURRENT_SCRIPT_DIR%\dashboard.bat %COMPILER_ARCH% 0 1 develop master
