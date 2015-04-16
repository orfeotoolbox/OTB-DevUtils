:: muparserx
:: source archive hosted on OrfeoToolBox website, archive was generated
:: from muParserX github
:: Source https://www.orfeo-toolbox.org/packages/muparserx_v3_0_5.zip
:: prerequisite: 
::   - CMake (>= 2.8.3)
::   - wget  (see GNUWin32 binaries)
::   - unzip, tar  (in OSGeo4W)
set CURRENT_SCRIPT_DIR=%~dp0

if NOT DEFINED OSGEO4W_ROOT (
echo Not an OSGeo shell
pause
goto exit
)

echo Need CMake to build package, version found
cmake -version
if errorlevel 1 (echo CMake not found ! & goto exit)

set P=muparserx
set V=3.0.5
set B=1

set W=%OSGEO4W_ROOT%\usr\src\osgeo4w\%P%
set R=../../release/%P%
mkdir "%W%"
mkdir "%W%\%P%-%V%-build"
mkdir "%OSGEO4W_ROOT%\usr\src\release\%P%"

copy %CURRENT_SCRIPT_DIR%package.cmd "%W%"
copy %CURRENT_SCRIPT_DIR%setup.hint "%W%"
copy %CURRENT_SCRIPT_DIR%CMakeLists.txt "%W%"

cd %W%
wget --no-check-certificate "https://www.orfeo-toolbox.org/packages/muparserx_v3_0_5.zip"
if errorlevel 1 (echo Download error & goto exit)

unzip %P%_v3_0_5.zip
if errorlevel 1 (echo Unzip error & goto exit)

rename %P%-2ace83b5411f1ab9940653c2bab0efa5140efb71 "%P%-%V%"

:: build
copy CMakeLists.txt %P%-%V%
cd %P%-%V%-build
cmake "../%P%-%V%" -G "NMake Makefiles" ^
    -DCMAKE_INSTALL_PREFIX:STRING="../%P%-%V%-install" ^
    -DCMAKE_BUILD_TYPE:STRING=Release ^
    -DBUILD_SHARED_LIBS:BOOL=ON ^
    -DBUILD_SAMPLES:BOOL=OFF
cmake --build . --config Release --target INSTALL
cd ..

:: package
tar -C %P%-%V%-install -cjf "%R%/%P%-%V%-%B%.tar.bz2" bin include lib
tar -C ../.. -cjf "%R%/%P%-%V%-%B%-src.tar.bz2"  osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint osgeo4w/%P%/CMakeLists.txt
tar -jtf "%R%/%P%-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R%\%P%-%V%-%B%.manifest"
copy setup.hint "%R%"
copy %P%-%V%\License.txt "%R%\%P%-%V%-%B%.txt"

:exit
