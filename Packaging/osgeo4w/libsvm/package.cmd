:: libKML
:: 
:: Source http://www.csie.ntu.edu.tw/~cjlin/libsvm/libsvm-3.20.tar.gz
:: prerequisite: setup.hint

set CURRENT_SCRIPT_DIR=%~dp0
cd %CURRENT_SCRIPT_DIR%

if NOT DEFINED OSGEO4W_ROOT (
echo Not an OSGeo shell
pause
goto exit
)

set P=libsvm
set V=3.20
set B=1

set W=%OSGEO4W_ROOT%\usr\src\osgeo4w\%P%
set R=../../release/%P%
mkdir "%W%"
rmdir "%W%\%P%-%V%" /s /q
rmdir "%W%\%P%-%V%-install" /s /q
mkdir "%OSGEO4W_ROOT%\usr\src\release\%P%"

copy %CURRENT_SCRIPT_DIR%package.cmd "%W%"
copy %CURRENT_SCRIPT_DIR%setup.hint "%W%"

cd %W%
wget http://www.csie.ntu.edu.tw/~cjlin/%P%/%P%-%V%.tar.gz
if errorlevel 1 (echo Download error & goto exit)

tar xvzf %P%-%V%.tar.gz
if errorlevel 1 (echo Untar error & goto exit)


:: build
rmdir "%P%-%V%-build" /s /q
mkdir "%P%-%V%-build"
cd "%P%-%V%-build"

xcopy /Y "%W%\\%P%-%V%" /E
if errorlevel 1 (echo Download error & goto exit)
nmake -f Makefile.win

cd  %W%
mkdir "%P%-%V%-install"
cd "%P%-%V%-install"
mkdir bin lib include
copy %W%\\%P%-%V%-build\\windows\*.exe bin
copy %W%\\%P%-%V%-build\\windows\*.dll bin
copy %W%\\%P%-%V%-build\\windows\*.lib lib
copy %W%\\%P%-%V%-build\\\svm.h include
cd ..

:: package
tar -C %P%-%V%-install -cjf "%R%/%P%-%V%-%B%.tar.bz2" bin lib include
tar -C ../.. -cjf "%R%/%P%-%V%-%B%-src.tar.bz2" osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint 
tar -jtf "%R%/%P%-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R%\%P%-%V%-%B%.manifest"
copy setup.hint "%R%"
copy %P%-%V%\\COPYRIGHT "%R%\\%P%-%V%-%B%.txt"

cd %CURRENT_SCRIPT_DIR%
:exit
