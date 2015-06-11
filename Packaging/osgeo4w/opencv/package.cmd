:: OpenCV
:: 
:: Source http://sourceforge.net/projects/opencvlibrary/files/opencv-unix/2.4.11/opencv-2.4.11.zip/download
:: prerequisite:
::   - wget  (see GNUWin32 binaries)
::   - unzip, tar  (in OSGeo4W)
::   - setup.hint

set CURRENT_SCRIPT_DIR=%~dp0
cd %CURRENT_SCRIPT_DIR%

if NOT DEFINED OSGEO4W_ROOT (
echo Not an OSGeo shell
pause
goto exit
)

set P=opencv
set V=2.4.11
set B=1

set W=%OSGEO4W_ROOT%\usr\src\osgeo4w\%P%
set R=../../release/%P%
rmdir "%W%" /s /q
rmdir "%R%" /s /q

mkdir "%W%"
mkdir "%OSGEO4W_ROOT%\usr\src\release\%P%"

copy %CURRENT_SCRIPT_DIR%package.cmd "%W%"
copy %CURRENT_SCRIPT_DIR%postbuild.py "%W%"
copy %CURRENT_SCRIPT_DIR%setup.hint "%W%"

cd %W%



wget http://sourceforge.net/projects/opencvlibrary/files/opencv-unix/%V%/%P%-%V%.zip
if errorlevel 1 (echo Download error & goto exit)

unzip %P%-%V%.zip
if errorlevel 1 (echo Untar error & goto exit)

::osgeo4w 32bit has libpng13.lib and 64bit has libpng16.lib. workaroud...
copy %OSGEO4W_ROOT%\\lib\\libpng13.lib %OSGEO4W_ROOT%\\lib\\libpng.lib /Y
copy %OSGEO4W_ROOT%\\lib\\libpng16.lib %OSGEO4W_ROOT%\\lib\\libpng.lib /Y

:: build
mkdir "%P%-%V%-build" 
cd %P%-%V%-build
cmake "../%P%-%V%" -G "NMake Makefiles" ^
 -DCMAKE_INSTALL_PREFIX:STRING="../%P%-%V%-install" ^
 -DCMAKE_INCLUDE_PATH:PATH=%OSGEO4W_ROOT%/include ^
 -DCMAKE_LIBRARY_PATH:PATH=%OSGEO4W_ROOT%/lib ^
 -DCMAKE_PREFIX_PATH:PATH=%OSGEO4W_ROOT% ^
 -DPYTHON_EXECUTABLE:FILEPATH=%OSGEO4W_ROOT%/bin/python.exe ^
 -DPYTHON_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/apps/Python27/include ^
 -DPYTHON_LIBRARY:FILEPATH=%OSGEO4W_ROOT%/apps/Python27/libs/python27.lib ^
 -DPYTHON_NUMPY_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/apps/Python27/lib/site-packages/numpy/core/include ^
 -DPYTHON_PACKAGES_PATH:PATH=%OSGEO4W_ROOT%/apps/Python27/lib/site-packages ^
 -DCMAKE_BUILD_TYPE:STRING=Release ^
 -DBUILD_TIFF:BOOL=OFF ^
 -DBUILD_TESTS:BOOL=OFF ^
 -DBUILD_PACKAGE:BOOL=OFF ^
 -DBUILD_PERF_TESTS:BOOL=OFF ^
 -DBUILD_DOCS:BOOL=OFF ^
 -DBUILD_ZLIB:BOOL=OFF ^
 -DBUILD_EXAMPLES:BOOL=OFF ^
 -DBUILD_JPEG:BOOL=OFF ^
 -DBUILD_PNG:BOOL=OFF ^
 -DWITH_OPENEXR:BOOL=OFF ^
 -DWITH_JASPER:BOOL=OFF ^
 -DBUILD_JASPER:BOOL=OFF ^
 -DBUILD_OPENEXR:BOOL=OFF ^
 -DBUILD_WITH_DEBUG_INFO:BOOL=OFF ^
 -DTIFF_LIBRARY:FILEPATH=%OSGEO4W_ROOT%/lib/libtiff_i.lib ^
 -DTIFF_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/include ^
 -DJPEG_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/include ^
 -DJPEG_LIBRARY:FILEPATH=%OSGEO4W_ROOT%/lib/jpeg_i.lib ^
 -DPNG_PNG_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/include ^
 -DPNG_LIBRARY:FILEPATH=%OSGEO4W_ROOT%/lib/libpng.lib ^ 
 -DZLIB_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%/include ^
 -DZLIB_LIBRARY:FILEPATH=%OSGEO4W_ROOT%/lib/zlib.lib ^
 -DWITH_FFMPEG:BOOL=OFF

cmake --build . --config Release --target INSTALL

cd ..

::package
CALL %OSGEO4W_ROOT%/bin/python.exe %W%\\postbuild.py 
tar -C %P%-%V%-%B% -cjf "%R%/%P%-%V%-%B%.tar.bz2" bin lib include share
tar -C ../.. -cjf "%R%/%P%-%V%-%B%-src.tar.bz2"  osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint osgeo4w/%P%/postbuild.py
tar -jtf "%R%/%P%-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R%\%P%-%V%-%B%.manifest"
copy setup.hint "%R%"
copy %P%-%V%\LICENSE "%R%\%P%-%V%-%B%.txt"

cd %CURRENT_SCRIPT_DIR%
 
:exit
