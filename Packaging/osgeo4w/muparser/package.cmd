:: muparser
:: 
:: Source http://sourceforge.net/projects/muparser/files/muparser/Version%202.2.3/muparser_v2_2_3.zip/download
:: prerequisite:
::   - wget  (see GNUWin32 binaries)
::   - unzip, tar  (in OSGeo4W)

set CURRENT_SCRIPT_DIR=%~dp0

if NOT DEFINED OSGEO4W_ROOT (
echo Not an OSGeo shell
pause
goto exit
)

set P=muparser
set V=2.2.3
set B=1


set W=%OSGEO4W_ROOT%\usr\src\osgeo4w\%P%
set R=../../release/%P%

rmdir "%W%" /s /q
rmdir "%R%" /s /q

mkdir "%W%"
mkdir "%OSGEO4W_ROOT%\usr\src\release\%P%"

copy %CURRENT_SCRIPT_DIR%package.cmd "%W%"
copy %CURRENT_SCRIPT_DIR%setup.hint "%W%"
copy %CURRENT_SCRIPT_DIR%CMakeLists.txt "%W%"

cd %W%
wget --no-check-certificate "https://docs.google.com/uc?export=download&id=0BzuB-ydOOoduLUNRanpDNV9iVk0" -O %P%-%V%.zip
if errorlevel 1 (echo Download error & goto exit)

unzip %P%-%V%.zip
if errorlevel 1 (echo Unzip error & goto exit)

rename %P%_v2_2_3 "%P%-%V%"

::patch
copy CMakeLists.txt %P%-%V%

:: build
mkdir %P%-%V%-build
cd %P%-%V%-build
cmake "../%P%-%V%" -G "NMake Makefiles" ^
    -DCMAKE_INSTALL_PREFIX:STRING="../%P%-%V%-install" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DBUILD_SHARED_LIBS:BOOL=ON

cmake --build . --config Release --target INSTALL
cmake . -DBUILD_SHARED_LIBS:BOOL=OFF
cmake --build . --config Release --target INSTALL
cd ..

:: package
tar -C %P%-%V%-install -cjf "%R%/%P%-%V%-%B%.tar.bz2" bin include lib
tar -C ../.. -cjf "%R%/%P%-%V%-%B%-src.tar.bz2"  osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint osgeo4w/%P%/CMakeLists.txt
tar -jtf "%R%/%P%-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R%\%P%-%V%-%B%.manifest"
copy setup.hint "%R%"
copy %P%-%V%\License.txt "%R%\%P%-%V%-%B%.txt"

:exit
