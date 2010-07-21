SET( CMAKE_BUILD_TYPE "Release" CACHE STRING "macSLRelease" FORCE )

SET( OTB_USE_EXTERNAL_FLTK OFF CACHE BOOL "debianRelease" FORCE )

#Need to compile gdal from source (as a 32b library)
#The compilation process of the gdfal library 
# export CFLAGS="-O2 -W -arch i386 "
# export CXXFLAGS="-O2 -W  -arch i386 "
# export LDFLAGS="-arch i386"
# 
# ./configure \
# --prefix=$GDAL_INSTALL_DIR \
# --with-png=internal \
# --with-libtiff=internal \
# --with-geotiff=internal
# 
# make
# make install

SET( GDAL_CONFIG "/Users/manuel/local/gdal-1.7.2-build/bin/gdal-config"  CACHE STRING "macSLRelease" FORCE )
SET( GDAL_INCLUDE_DIR "/Users/manuel/local/gdal-1.7.2-build/include"  CACHE STRING "macSLRelease" FORCE )
SET( GDAL_LIBRARY "/Users/manuel/local/gdal-1.7.2-build/lib/libgdal.dylib" CACHE STRING "macSLRelease" FORCE )
SET( OGR_INCLUDE_DIRS "/Users/manuel/local/gdal-1.7.2-build/include"  CACHE STRING "macSLRelease" FORCE )

SET( TIFF_INCLUDE_DIRS "/Users/manuel/local/gdal-1.7.2/frmts/gtiff/libtiff"  CACHE STRING "macSLRelease" FORCE )
SET( GEOTIFF_INCLUDE_DIRS "/Users/manuel/local/gdal-1.7.2/frmts/gtiff/libgeotiff"  CACHE STRING "macSLRelease" FORCE )
SET( JPEG_INCLUDE_DIR "/Users/manuel/local/gdal-1.7.2/frmts/jpeg/libjpeg"  CACHE STRING "macSLRelease" FORCE )
SET( JPEG_INCLUDE_DIRS "/Users/manuel/local/gdal-1.7.2/frmts/jpeg/libjpeg" CACHE STRING "macSLRelease" FORCE )

OPTION(OTB_USE_LIBLAS OFF CACHE BOOL "macSLRelease" FORCE )

SET( CMAKE_OSX_ARCHITECTURES "i386"  CACHE STRING "macSLRelease" FORCE )
 