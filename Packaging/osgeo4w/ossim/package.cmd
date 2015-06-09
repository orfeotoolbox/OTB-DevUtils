:: ossim
:: 
:: Source https://www.orfeo-toolbox.org//packages/ossim-minimal-r23092.tar.gz
:: prerequisite: setup.hint.ossim

set CURRENT_SCRIPT_DIR=%~dp0
cd %CURRENT_SCRIPT_DIR%

if NOT DEFINED OSGEO4W_ROOT (
echo Not an OSGeo shell
pause
goto exit
)

set P=ossim
set V=1.8.19
set B=1

set W=%OSGEO4W_ROOT%\usr\src\osgeo4w\%P%
set R=../../release/%P%
mkdir "%W%"

rmdir "%W%\%P%-%V%-install" /s /q
mkdir "%OSGEO4W_ROOT%\usr\src\release\%P%"

copy %CURRENT_SCRIPT_DIR%package.cmd "%W%"
copy %CURRENT_SCRIPT_DIR%setup.hint "%W%"
copy %CURRENT_SCRIPT_DIR%FindGEOS.cmake"%W%/CMakeModules"

cd %W%
rmdir "%W%\%P%-%V%" /s /q
::wget https://www.orfeo-toolbox.org/packages/ossim-minimal-r23092.tar.gz --no-check-certificate
::if errorlevel 1 (echo Download error & goto exit)

tar xzf %P%-minimal-r23092.tar.gz
if errorlevel 1 (echo Untar error & goto exit)

rename OSSIM-minimal %P%-%V%

:: build
rmdir "%P%-%V%-build" /s /q
mkdir "%P%-%V%-build"

cd %P%-%V%-build
cmake "../%P%-%V%" -G "NMake Makefiles" ^
 -DCMAKE_BUILD_TYPE:STRING=Release ^
 -DBUILD_SHARED_LIBS:BOOL=OFF ^
      -DCMAKE_INSTALL_PREFIX:PATH=../%P%-%V%-install ^
      -DCMAKE_VERBOSE_MAKEFILE:BOOL=ON ^
      -DCMAKE_MODULE_PATH:PATH="%OSSIM_SRC%/CMakeModules" ^
      -DCMAKE_PREFIX_PATH:PATH="%OSGEO4W_ROOT%/usr/src/osgeo4w/geos_all/geos_all-3.4.2-install" ^
      -DGEOTIFF_INCLUDE_DIR:PATH="%OSGEO4W_ROOT%/include" ^
      -DGEOTIFF_LIBRARY:FILEPATH="%OSGEO4W_ROOT%/lib/geotiff_i.lib" ^
      -DJPEG_INCLUDE_DIR:PATH="%OSGEO4W_ROOT%/include" ^
      -DJPEG_LIBRARY:FILEPATH="%OSGEO4W_ROOT%/lib/jpeg_i.lib" ^
      -DOPENTHREADS_INCLUDE_DIR:PATH="%OSGEO4W_ROOT%/include" ^
      -DOPENTHREADS_LIBRARY:FILEPATH="%OSGEO4W_ROOT%/lib/OpenThreads.lib" ^
      -DTIFF_INCLUDE_DIR:PATH="%OSGEO4W_ROOT%/include" ^
      -DTIFF_LIBRARY:FILEPATH="%OSGEO4W_ROOT%/lib/libtiff_i.lib" ^
      -DZLIB_INCLUDE_DIR:PATH="%OSGEO4W_ROOT%/include" ^
      -DZLIB_LIBRARY:FILEPATH="%OSGEO4W_ROOT%/lib/zlib.lib" ^
      -DBUILD_OSSIM_FREETYPE_SUPPORT:BOOL=ON ^
      -DBUILD_OSSIM_MPI_SUPPORT:BOOL=OFF

      
cmake --build . --config Release --target INSTALL

cd ..

:: package
 tar -C %P%-%V%-install -cjf "%R%/%P%-%V%-%B%.tar.bz2" include lib bin share
tar -C ../.. -cjf "%R%/%P%-%V%-%B%-src.tar.bz2"  osgeo4w/%P%/package.cmd osgeo4w/%P%/setup.hint osgeo4w/%P%/FindGEOS.cmake


tar -jtf "%R%/%P%-%V%-%B%.tar.bz2" | sed "s@\\\@/@g" | sed "s@//@/@g" > "%R%\%P%-%V%-%B%.manifest"
copy setup.hint "%R%"
copy %P%-%V%\LICENSE "%R%\%P%-%V%-%B%.txt"

cd %CURRENT_SCRIPT_DIR%
:exit
