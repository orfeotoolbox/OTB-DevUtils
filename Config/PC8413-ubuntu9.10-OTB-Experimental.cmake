
SET (CTEST_SOURCE_DIRECTORY "/home/jmalik/Projets/otb/src/OTB/")
SET (CTEST_BINARY_DIRECTORY "/home/jmalik/Projets/otb/build/debug/OTB/")

# which ctest command to use for running the dashboard
SET (CTEST_COMMAND 
  "ctest -j2 -D Experimental -A ${CTEST_BINARY_DIRECTORY}/CMakeCache.txt -V"
  )

# what cmake command to use for configuring this dashboard
SET (CTEST_CMAKE_COMMAND 
  "cmake -G \"Eclipse CDT4 - Unix Makefiles\""
  )

# should ctest wipe the binary tree before running
SET (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY FALSE)

# this is the initial cache to use for the binary tree, be careful to escape
# any quotes inside of this string if you use it
SET (CTEST_INITIAL_CACHE "
MAKECOMMAND:STRING=/usr/bin/make -i -k -j2
BUILDNAME:STRING=ubuntu9.10-gcc441-dbg
SITE:STRING=PC8413-ubuntu9.10

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/home/jmalik/Projets/otb/src/OTB-LargeInput
OTB_DATA_ROOT:STRING=/home/jmalik/Projets/otb/src/OTB-Data

CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

CMAKE_BUILD_TYPE:STRING=Debug
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=OFF

OTB_USE_CURL:BOOL=ON
OTB_USE_PQXX:BOOL=OFF
OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_EXTERNAL_EXPAT:BOOL=ON
USE_FFTWD:BOOL=OFF
USE_FFTWF:BOOL=OFF
OTB_GL_USE_ACCEL:BOOL=OFF
ITK_USE_REVIEW:BOOL=ON 
ITK_USE_OPTIMIZED_REGISTRATION_METHODS:BOOL=ON 
OTB_USE_MAPNIK:BOOL=OFF
CMAKE_INSTALL_PREFIX:STRING=/home/jmalik/Projets/otb/install/OTB-debug

GDALCONFIG_EXECUTABLE:FILEPATH=/home/jmalik/Utils/bin/gdal-1.7.2/bin/gdal-config
GDAL_CONFIG:FILEPATH=/home/jmalik/Utils/bin/gdal-1.7.2/bin/gdal-config
GDAL_INCLUDE_DIR:STRING=/home/jmalik/Utils/bin/gdal-1.7.2/include
GDAL_LIBRARY:FILEPATH=/home/jmalik/Utils/bin/gdal-1.7.2/lib/libgdal.so
OGR_INCLUDE_DIRS:PATH=/home/jmalik/Utils/bin/gdal-1.7.2/include
GEOTIFF_INCLUDE_DIRS:PATH=/home/jmalik/Utils/src/gdal-1.7.2/frmts/gtiff/libgeotiff
TIFF_INCLUDE_DIRS:PATH=/home/jmalik/Utils/src/gdal-1.7.2/frmts/gtiff/libtiff
JPEG_INCLUDE_DIRS:PATH=/home/jmalik/Utils/src/gdal-1.7.2/frmts/jpeg/libjpeg

")

# set any extra envionment varibles here
SET (CTEST_ENVIRONMENT
 "DISPLAY=:0"
)

