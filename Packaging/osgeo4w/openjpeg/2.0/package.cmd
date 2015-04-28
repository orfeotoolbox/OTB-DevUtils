:: openjpeg
:: 
:: Source http://sourceforge.net/projects/openjpeg.mirror/files/2.0.0/openjpeg-2.0.0.tar.gz/download
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

set P=openjpeg
set V=2.0.0
set B=2

set W=%OSGEO4W_ROOT%\usr\src\osgeo4w\%P%
set R=../../release/%P%
mkdir "%W%"
rmdir "%W%\%P%-%V%" /s /q
rmdir "%W%\%P%-%V%-build" /s /q
rmdir "%W%\%P%-%V%-install" /s /q
mkdir "%W%\%P%-%V%-build"
mkdir "%OSGEO4W_ROOT%\usr\src\release\%P%"

copy %CURRENT_SCRIPT_DIR%package.cmd "%W%"
copy %CURRENT_SCRIPT_DIR%setup.hint "%W%"

cd %W%
wget "http://sourceforge.net/projects/%P%.mirror/files/%V%/%P%-%V%.tar.gz/download"
if errorlevel 1 (echo Download error & goto exit)

tar -xzf %P%-%V%.tar.gz
if errorlevel 1 (echo Tar error & goto exit)

:: build
cd %P%-%V%-build
cmake "../%P%-%V%" -G "NMake Makefiles" ^
 -DCMAKE_BUILD_TYPE:STRING=Release ^
 -DBUILD_SHARED_LIBS:BOOL=ON ^
 -DCMAKE_INSTALL_PREFIX:STRING="../%P%-%V%-install" ^
 -DBUILD_JPWL:BOOL=OFF ^
 -DBUILD_MJ2:BOOL=OFF ^
 -DBUILD_JPIP:BOOL=OFF ^
 -DBUILD_JAVA:BOOL=OFF ^
 -DTIFF_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/include ^
 -DTIFF_LIBRARY:PATH=%OSGEO4W_ROOT%/lib/libtiff_i.lib ^
 -DPNG_PNG_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/include/libpng16 ^
 -DPNG_LIBRARY:PATH=%OSGEO4W_ROOT%/lib/libpng16.lib ^
 -DZLIB_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/include ^
 -DZLIB_LIBRARY:PATH=%OSGEO4W_ROOT%/lib/zlib.lib
cmake --build . --config Release --target INSTALL
cd ..

:: msvc dll's not needed in the package
del %P%-%V%-install\bin\Microsoft.VC90.CRT.manifest
del %P%-%V%-install\bin\msvc*.dll

:: package
tar -C %P%-%V%-install -cjf "%R%/%P%-%V%-%B%.tar.bz2" bin include lib
tar -C ../.. -cjf "%R%/%P%-%V%-%B%-src.tar.bz2"  osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint
tar -jtf "%R%/%P%-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R%\%P%-%V%-%B%.manifest"
copy setup.hint "%R%"
copy %P%-%V%\LICENSE "%R%\%P%-%V%-%B%.txt"

:exit
