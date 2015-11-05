:: GEOS
:: 
:: Source http://download.osgeo.org/geos/geos-3.5.0.tar.bz2
:: prerequisite: setup.hint

set CURRENT_SCRIPT_DIR=%~dp0
cd %CURRENT_SCRIPT_DIR%

if NOT DEFINED OSGEO4W_ROOT (
echo Not an OSGeo shell
pause
goto exit
)

set P=geos
set P1=geos
set V=3.5.0
set B=1

set W=%OSGEO4W_ROOT%\usr\src\osgeo4w\%P%
set R=../../release/%P%
set R1=%OSGEO4W_ROOT%\usr\src\release\%P%

rmdir "%W%" /s /q
rmdir "%R1%" /s /q

mkdir "%W%"
mkdir "%R1%"

copy %CURRENT_SCRIPT_DIR%package.cmd "%W%"
copy %CURRENT_SCRIPT_DIR%setup.hint "%W%"
copy %CURRENT_SCRIPT_DIR%CMakeLists.txt "%W%"
copy %CURRENT_SCRIPT_DIR%GenerateSourceGroups.cmake "%W%"

cd %W%
wget http://download.osgeo.org/%P1%/%P1%-%V%.tar.bz2
if errorlevel 1 (echo Download error & goto exit)

tar xf %P1%-%V%.tar.bz2
if errorlevel 1 (echo Untar error & goto exit)

copy "%W%\CMakeLists.txt " "%P%-%V%"
copy %W%\GenerateSourceGroups.cmake "%P%-%V%\cmake\modules"

:: build
mkdir "%P%-%V%-build"

cd %P%-%V%-build
cmake "../%P%-%V%" -G "NMake Makefiles" ^
 -DCMAKE_BUILD_TYPE:STRING=Release ^
 -DBUILD_SHARED_LIBS:BOOL=ON ^
 -DCMAKE_CXX_FLAGS:STRING="-DNOMINMAX  /EHsc" ^
 -DCMAKE_INSTALL_PREFIX:STRING="../%P%-%V%-install" ^
 -DGEOS_ENABLE_TESTS:BOOL=OFF

cmake --build . --config Release --target INSTALL

cd ..

:: package
tar -C %P%-%V%-install -cjf "%R%/%P%-%V%-%B%.tar.bz2" include lib bin
tar -C ../.. -cjf "%R%/%P%-%V%-%B%-src.tar.bz2" osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint osgeo4w/%P%/GenerateSourceGroups.cmake osgeo4w/%P%/CMakeLists.txt

tar -jtf "%R%/%P%-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R%/%P%-%V%-%B%.manifest"
copy setup.hint "%R1%"
copy %P%-%V%\COPYING "%R1%\%P%-%V%-%B%.txt"

cd %CURRENT_SCRIPT_DIR%

:exit
