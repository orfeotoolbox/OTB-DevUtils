@echo off
set /A ARGS_COUNT=0
for %%A in (%*) do set /A ARGS_COUNT+=1
if %ARGS_COUNT% NEQ 2 (goto :Usage)
if NOT DEFINED OSGEO4W_ROOT (goto :NoOSGEO4W)
set P=%1
set N=%2
set R=%OSGEO4W_ROOT%\usr\src\release\%N%
rmdir %R% /s /q
mkdir %R%

set PKG_SOURCE_DIR=%~dp0

::tar -C %P% -cvjf "%P%.tar.bz2" "."
@echo on
copy %N%_LIC.txt "%R%\%P%.txt"
copy "%P%.tar.bz2"  "%R%"

cd %PKG_SOURCE_DIR%
tar  -cjf "%P%-src.tar.bz2" osgeo4w-otb.py otb_make_tar.cmd template-%N% setup.hint.%N%

copy "setup.hint.%N%" "%R%\setup.hint"

copy "%P%-src.tar.bz2"  "%R%"

rm -f "%P%-src.tar.bz2"

cd %R%

tar -jtf "%P%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%P%.manifest"

@echo off
goto :END
:Usage
echo You need to provide 1 argument to the script:
echo 1. path to the otb packaged version directory
GOTO :END
:NoOSGEO4W
echo You need to run this script from an OSGeo4W shell
GOTO :END
:END