:: GEOS
:: 
:: Source http://download.osgeo.org/geos/geos-3.4.2.tar.bz2
:: prerequisite: setup.hint

set CURRENT_SCRIPT_DIR=%~dp0
cd %CURRENT_SCRIPT_DIR%

if NOT DEFINED OSGEO4W_ROOT (
echo Not an OSGeo shell
pause
goto exit
)

set P=geos_all
set P1=geos
set V=3.4.2
set B=2

set W=%OSGEO4W_ROOT%\usr\src\osgeo4w\%P%
set R=../../release/%P%
mkdir "%W%"

rmdir "%W%\%P%-%V%-install" /s /q
mkdir "%OSGEO4W_ROOT%\usr\src\release\%P%"

copy %CURRENT_SCRIPT_DIR%package.cmd "%W%"
copy %CURRENT_SCRIPT_DIR%setup.hint "%W%"

cd %W%
rmdir "%W%\%P%-%V%" /s /q
wget http://download.osgeo.org/%P1%/%P1%-%V%.tar.bz2
if errorlevel 1 (echo Download error & goto exit)

tar xf %P1%-%V%.tar.bz2
if errorlevel 1 (echo Untar error & goto exit)

rename %P1%-%V% %P%-%V%

:: build
rmdir "%P%-%V%-build" /s /q
mkdir "%P%-%V%-build"

cd %P%-%V%-build
cmake "../%P%-%V%" -G "NMake Makefiles" ^
 -DCMAKE_BUILD_TYPE:STRING=Release ^
 -DBUILD_SHARED_LIBS:BOOL=ON ^
 -DCMAKE_INSTALL_PREFIX:STRING="../%P%-%V%-install" ^
 -DGEOS_ENABLE_TESTS:BOOL=OFF

cmake --build . --config Release --target INSTALL

cd ..

:: package
 tar -C %P%-%V%-install -cjf "%R%/%P%-%V%-%B%.tar.bz2" include lib bin
tar -C ../.. -cjf "%R%/%P%-%V%-%B%-src.tar.bz2" osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint

tar -jtf "%R%/%P%-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R%\%P%-%V%-%B%.manifest"
copy setup.hint "%R%"
copy %P%-%V%\COPYING "%R%\%P%-%V%-%B%.txt"

cd %CURRENT_SCRIPT_DIR%

:exit
