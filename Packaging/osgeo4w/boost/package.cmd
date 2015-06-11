:: Boost
:: 
:: Source http://sourceforge.net/projects/boost/files/boost/1.56.0/boost_1_56_0.tar.bz2/download
:: prerequisite: setup.hint

set CURRENT_SCRIPT_DIR=%~dp0
cd %CURRENT_SCRIPT_DIR%

if NOT DEFINED OSGEO4W_ROOT (
echo Not an OSGeo shell
pause
goto exit
)

set P=boost
set V=1.56.0
set SV=1_56_0
set B=1

set W=%OSGEO4W_ROOT%\usr\src\osgeo4w\%P%
set R=../../release/%P%

rmdir "%W%" /s /q
rmdir "%R%" /s /q

mkdir "%W%"
mkdir "%OSGEO4W_ROOT%\usr\src\release\%P%"

copy %CURRENT_SCRIPT_DIR%package.cmd "%W%"
copy %CURRENT_SCRIPT_DIR%setup.hint "%W%"


cd %W%
rmdir "%W%\%P%-%V%" /s /q
wget http://sourceforge.net/projects/%P%/files/%P%/%V%/%P%_1_56_0.tar.bz2/download
if errorlevel 1 (echo Download error & goto exit)

tar xvf %P%_%SV%.tar.bz2
if errorlevel 1 (echo Untar error & goto exit)

rename %P%_%SV% "%P%-%V%"

:: build
mkdir "%P%-%V%-build"

cd "%W%\%P%-%V%"
CALL bootstrap.bat

CALL b2 link=shared threading=multi variant=release --build-dir="%W%\%P%-%V%-build" --prefix="%W%\%P%-%V%-install" install

::package

::move .dlls into bin aka follow unix directory naming conventions
cd "%W%\%P%-%V%-install"
mkdir bin
move lib\\*.dll bin\\

cd %W%
tar -C %P%-%V%-install -cjf "%R%/%P%-%V%-%B%.tar.bz2" bin lib include
tar -C ../.. -cjf "%R%/%P%-%V%-%B%-src.tar.bz2"  osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint
tar -jtf "%R%/%P%-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R%\%P%-%V%-%B%.manifest"
copy setup.hint "%R%"
copy %W%\%P%-%V%\LICENSE_1_0.txt "%R%\%P%-%V%-%B%.txt"

cd %CURRENT_SCRIPT_DIR%
:exit
