@echo off

set OSSIM_SRC=C:/Users/jmalik/Dashboard/src/ossim-svn/ossim_package_support/cmake
set OSSIM_DEV_HOME=C:/Users/jmalik/Dashboard/src/ossim-svn

set OSSIM_BUILD=C:/Users/jmalik/Dashboard/build/ossim-trunk-gui
set OSSIM_INSTALL=C:/Users/jmalik/Dashboard/install/ossim-trunk-gui

cmake -E remove_directory %OSSIM_BUILD%
cmake -E make_directory %OSSIM_BUILD%

cmake -E remove_directory %OSSIM_INSTALL%
cmake -E make_directory %OSSIM_INSTALL%

cd %OSSIM_BUILD%
cmake "%OSSIM_SRC%" -G "Visual Studio 10" ^
      -DOSSIM_DEV_HOME:STRING="%OSSIM_DEV_HOME%" ^
      -DCMAKE_BUILD_TYPE:STRING=Release ^
      -DCMAKE_INSTALL_PREFIX:PATH=%OSSIM_INSTALL% ^
      -DCMAKE_MODULE_PATH:PATH=%OSSIM_SRC%/CMakeModules ^
      -DCURL_INCLUDE_DIR:PATH="%OSGEO4W_ROOT%/include" ^
      -DCURL_LIBRARY:FILEPATH="%OSGEO4W_ROOT%/lib/libcurl_imp.lib" ^
      -DEXPAT_INCLUDE_DIR:PATH="%OSGEO4W_ROOT%/include" ^
      -DEXPAT_LIBRARY:FILEPATH="%OSGEO4W_ROOT%/lib/libexpat.lib" ^
      -DGEOS_INCLUDE_DIR:PATH="%OSGEO4W_ROOT%/include" ^
      -DGEOS_LIBRARY:FILEPATH="%OSGEO4W_ROOT%/lib/geos_c.lib" ^
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
      -DFFTW3_INCLUDE_DIR:PATH="%OSGEO4W_ROOT%/include" ^
      -DFFTW3_LIBRARY:FILEPATH="%OSGEO4W_ROOT%/lib/fftw3.lib" ^
      -DFREETYPE_INCLUDE_DIR_ft2build:PATH="%OSGEO4W_ROOT%/include/freetype" ^
      -DFREETYPE_INCLUDE_DIR_freetype2:PATH="%OSGEO4W_ROOT%/include/freetype" ^
      -DFREETYPE_LIBRARY:FILEPATH="%OSGEO4W_ROOT%/lib/freetype237.lib" ^
      -DFFMPEG_ROOT:PATH="%OSGEO4W_ROOT%" ^
	  -DFFMPEG_STDINT_INCLUDE_DIR:PATH="%OSGEO4W_ROOT%/include" ^
      -DBUILD_OSSIM_FREETYPE_SUPPORT:BOOL=ON ^
      -DBUILD_OSSIM_MPI_SUPPORT:BOOL=OFF ^
      -DBUILD_WMS:BOOL=ON ^
      -DBUILD_OSSIMPREDATOR:BOOL=ON ^
      -DBUILD_OMS:BOOL=OFF ^
      -DBUILD_OSSIMPLANET:BOOL=OFF ^
      -DBUILD_OSSIMPLANETQT:BOOL=OFF ^
      -DBUILD_OSSIMQT4:BOOL=ON ^
      -DBUILD_OSSIMGUI:BOOL=ON ^
      -DBUILD_CSMAPI:BOOL=OFF ^
      -DBUILD_OSSIMCSM_PLUGIN:BOOL=OFF ^
      -DBUILD_OSSIM_PLUGIN:BOOL=OFF ^
	  -DOSG_DIR:PATH="%OSGEO4W_ROOT%"

cmake --build . --config Release --target INSTALL > log_ossim.txt 2>&1

