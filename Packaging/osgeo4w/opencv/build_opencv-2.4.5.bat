set ROOT_DIR=C:\Users\jmalik\Dashboard\tools

set SRC_DIR=%ROOT_DIR%\src\opencv-2.4.5
set BUILD_DIR=%ROOT_DIR%\build\opencv-2.4.5

mkdir %BUILD_DIR%
cd %BUILD_DIR%
rm -rf *

cmake ^
 -DCMAKE_INCLUDE_PATH:PATH=%OSGEO4W_ROOT%include ^
 -DCMAKE_LIBRARY_PATH:PATH=%OSGEO4W_ROOT%lib ^
 -DPYTHON_EXECUTABLE:FILEPATH=%OSGEO4W_ROOT%bin/python.exe ^
 -DPYTHON_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%apps/Python27/include ^
 -DPYTHON_LIBRARY:FILEPATH=%OSGEO4W_ROOT%apps/Python27/libs/python27.lib ^
 -DPYTHON_NUMPY_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%apps/Python27/lib/site-packages/numpy/core/include ^
 -DPYTHON_PACKAGES_PATH:PATH=%OSGEO4W_ROOT%apps/Python27/lib/site-packages ^
 -DBUILD_TIFF:BOOL=OFF ^
 -DTIFF_LIBRARY:FILEPATH=%OSGEO4W_ROOT%lib/libtiff_i.lib ^
 -DTIFF_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%include ^
 -DBUILD_JPEG:BOOL=OFF ^
 -DJPEG_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%include ^
 -DJPEG_LIBRARY:FILEPATH=%OSGEO4W_ROOT%lib/jpeg_i.lib ^
 -DBUILD_PNG:BOOL=OFF ^
 -DPNG_PNG_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%include ^
 -DPNG_LIBRARY:FILEPATH=%OSGEO4W_ROOT%lib/libpng13.lib ^
 -DBUILD_ZLIB:BOOL=OFF ^
 -DZLIB_INCLUDE_DIR:PATH=%OSGEO4W_ROOT%include ^
 -DZLIB_LIBRARY:FILEPATH=%OSGEO4W_ROOT%lib/zlib.lib ^
 -DWITH_OPENEXR:BOOL=OFF ^
 -DWITH_JASPER:BOOL=OFF ^
 -DWITH_FFMPEG:BOOL=OFF ^
 -DWITH_FFMPEG:BOOL=OFF ^
 %SRC_DIR%

 cmake --build . --config Release --target INSTALL
 
 rm %OSGEO4W_ROOT%apps/Python27/lib/site-packages/cv2.lib
 
 mkdir -p %BUILD_DIR%/install/apps/Python27/lib/site-packages
 mv %OSGEO4W_ROOT%apps/Python27/lib/site-packages/cv.py %BUILD_DIR%/install/apps/Python27/lib/site-packages
 mv %OSGEO4W_ROOT%apps/Python27/lib/site-packages/cv2.pyd %BUILD_DIR%/install/apps/Python27/lib/site-packages