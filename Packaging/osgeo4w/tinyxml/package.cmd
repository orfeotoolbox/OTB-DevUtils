:: tinyXML
:: 
:: Source http://sourceforge.net/projects/tinyxml/files/tinyxml/2.6.2/tinyxml_2_6_2.tar.gz/download
:: prerequisite:
::   - wget  (see GNUWin32 binaries)
::   - unzip, tar  (in OSGeo4W)

set CURRENT_SCRIPT_DIR=%~dp0
cd %CURRENT_SCRIPT_DIR%

if NOT DEFINED OSGEO4W_ROOT (
echo Not an OSGeo shell
pause
goto exit
)

set P=tinyxml
set V=2.6.2
set B=1

set W=%OSGEO4W_ROOT%\usr\src\osgeo4w\%P%
set R=../../release/%P%
mkdir "%W%"

rmdir "%W%" /s /q
rmdir "%R%" /s /q

mkdir "%W%"
mkdir %W%\%P%-%V%-build

mkdir "%OSGEO4W_ROOT%\usr\src\release\%P%"

copy %CURRENT_SCRIPT_DIR%package.cmd "%W%"
copy %CURRENT_SCRIPT_DIR%setup.hint "%W%"
copy %CURRENT_SCRIPT_DIR%CMakeLists.txt "%W%"

cd %W%

wget http://sourceforge.net/projects/%P%/files/%P%/%V%/%P%_2_6_2.tar.gz/download
if errorlevel 1 (echo Download error & goto exit)

tar xvzf %P%_2_6_2.tar.gz
if errorlevel 1 (echo Untar error & goto exit)
rename %P% "%P%-%V%"

::patch
copy CMakeLists.txt "%P%-%V%"

:: build
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
copy %P%-%V%\readme.txt "%R%\%P%-%V%-%B%.txt"

cd %CURRENT_SCRIPT_DIR%
:exit
