:: libKML
:: 
:: Source http://ftp.de.debian.org/debian/pool/main/libk/libkml/libkml_1.3.0~r863.orig.tar.gz
:: prerequisite: setup.hint

set CURRENT_SCRIPT_DIR=%~dp0
cd %CURRENT_SCRIPT_DIR%

if NOT DEFINED OSGEO4W_ROOT (
echo Not an OSGeo shell
pause
goto exit
)

set P=libkml
set V=1.3.0
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
wget http://ftp.de.debian.org/debian/pool/main/libk/libkml/libkml_1.3.0~r863.orig.tar.gz
if errorlevel 1 (echo Download error & goto exit)

tar xvzf %P%_%V%~r863.orig.tar.gz
if errorlevel 1 (echo Untar error & goto exit)

rename libkml-1.3.0~r863 "%P%-%V%"

rmdir "%P%-%V%\testdata" /s /q
rmdir "%P%-%V%\examples" /s /q

::patches
copy %CURRENT_SCRIPT_DIR%CMakeLists.txt "%W%\%P%-%V%\"
copy %CURRENT_SCRIPT_DIR%util.h "%W%\%P%-%V%\src\kml\base\"
copy %CURRENT_SCRIPT_DIR%file_posix.cc "%W%\%P%-%V%\src\kml\base\"


:: build
mkdir "%P%-%V%-build"

cd %P%-%V%-build
cmake "../%P%-%V%" -G "NMake Makefiles" ^
 -DCMAKE_BUILD_TYPE:STRING=Release ^
 -DBUILD_SHARED_LIBS:BOOL=ON ^
 -DCMAKE_INSTALL_PREFIX:STRING="../%P%-%V%-install" ^
 -DEXPAT_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/include ^
 -DEXPAT_LIBRARY:FILEPATH=%OSGEO4W_ROOT%/lib/libexpat.lib ^
 -DZLIB_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/include ^
 -DZLIB_LIBRARY:FILEPATH=%OSGEO4W_ROOT%/lib/zlib.lib ^
 -DBoost_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/include/boost-1_56

cmake --build . --config Release --target INSTALL


:: package
 tar -C %P%-%V%-install -cjf "%R%/%P%-%V%-%B%.tar.bz2" include lib share
tar -C ../.. -cjf "%R%/%P%-%V%-%B%-src.tar.bz2"  osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint osgeo4w/%P%/%P%-%V%/CMakeLists.txt  osgeo4w/%P%/%P%-%V%/src/kml/base/file_posix.cc osgeo4w/%P%/%P%-%V%/src/kml/base/util.h


tar -jtf "%R%/%P%-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R%\%P%-%V%-%B%.manifest"
copy setup.hint "%R%"
copy %P%-%V%\LICENSE "%R%\%P%-%V%-%B%.txt"

:exit
