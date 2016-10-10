SETLOCAL
@echo on

IF %1.==. ( echo "No arch" 
goto Fin )

set COMPILER_ARCH=%1

cmake -DCOMPILER_ARCH=%COMPILER_ARCH% -P C:\dashboard\scripts\nightly.cmake 
:: >C:\dashboard\logs\nightly.log 2>&1

goto Fin

:Fin
echo "called :Fin. End of nightly.bat script."
ENDLOCAL

::cmd /C start /wait %SCRIPTS_DIR%\dashboard.bat %COMPILER_ARCH% 0 1 develop master