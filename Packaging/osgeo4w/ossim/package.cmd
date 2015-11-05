:: ossim
:: 
:: Source http://download.osgeo.org/ossim/source/ossim-1.8.20/ossim-1.8.20.zip
:: prerequisite: setup.hint.ossim

set CURRENT_SCRIPT_DIR=%~dp0
cd %CURRENT_SCRIPT_DIR%

if NOT DEFINED OSGEO4W_ROOT (
echo Not an OSGeo shell
pause
goto exit
)

set P=ossim
set V=1.8.20
set B=1

set W=%OSGEO4W_ROOT%\usr\src\osgeo4w\%P%
set R1=%OSGEO4W_ROOT%\usr\src\release\%P%
set R=../../release/%P%

rmdir "%W%" /s /q
mkdir "%W%"

rmdir "%R1%" /s /q
mkdir "%R1%"

copy %CURRENT_SCRIPT_DIR%package.cmd "%W%"
copy %CURRENT_SCRIPT_DIR%setup.hint "%W%"
copy %CURRENT_SCRIPT_DIR%ossim-1.8.20-fixes.patch "%W%"

cd %W%

wget http://download.osgeo.org/ossim/source/%P%-%V%/%P%-%V%.zip
if errorlevel 1 (echo Download error & goto exit)

unzip %P%-%V%.zip
if errorlevel 1 (echo Unzip error & goto exit)

patch -p0 < ossim-1.8.20-fixes.patch


::build
rmdir "%P%-%V%-build" /s /q
mkdir "%P%-%V%-build"

rmdir "%P%-%V%-install" /s /q

cd %P%-%V%-build

cmake "../%P%-%V%/%P%" -G "NMake Makefiles" ^
 -DCMAKE_BUILD_TYPE:STRING=Release ^
 -DBUILD_SHARED_LIBS:BOOL=ON ^
 -DCMAKE_INSTALL_PREFIX:PATH=../%P%-%V%-install ^
 -DCMAKE_MODULE_PATH:PATH="%W%/%P%-%V%/ossim_package_support/cmake/CMakeModules" ^
 -DGEOS_DIR:PATH="%OSGEO4W_ROOT%" ^
 -DCMAKE_PREFIX_PATH:PATH="%OSGEO4W_ROOT%" ^
 -DWIN32_USE_MP:BOOL=ON ^
 -DJPEG_NAMES:STRING="jpeg_i" ^
 -DBUILD_OSSIM_TEST_APPS:BOOL=OFF ^
 -DBUILD_OSSIM_CURL_APPS:BOOL=OFF ^
 -DBUILD_OSSIM_FREETYPE_SUPPORT:BOOL=OFF ^
 -DBUILD_OSSIM_MPI_SUPPORT:BOOL=OFF 

 cmake --build . --config Release --target INSTALL

cd ..

:: package
 tar -C %P%-%V%-install -cjf "%R%/%P%-%V%-%B%.tar.bz2" include lib bin share
tar -C ../.. -cjf "%R%/%P%-%V%-%B%-src.tar.bz2"  osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint osgeo4w/%P%/ossim-1.8.20-fixes.patch

tar -jtf "%R%/%P%-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R%/%P%-%V%-%B%.manifest"
copy setup.hint "%R%"
copy %P%-%V%\%P%\LICENSE.txt "%R1%\%P%-%V%-%B%.txt"

cd %CURRENT_SCRIPT_DIR%
:exit
