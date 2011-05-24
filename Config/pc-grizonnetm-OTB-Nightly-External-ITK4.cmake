
SET (CTEST_SOURCE_DIRECTORY "/mnt/dd-2/OTB/trunk/OTB-SandBox/")
SET (CTEST_BINARY_DIRECTORY "/mnt/dd-2/OTB/OTB-Binary-Experimental-ITK4/")


# which ctest command to use for running the dashboard
SET (CTEST_COMMAND 
  "ctest -j6 -D Experimental -A /mnt/dd-2/OTB/trunk/OTB-DevUtils/Config/pc-grizonnetm-OTB-Experimental-External-ITK4.cmake -V"
  )

# what cmake command to use for configuring this dashboard
SET (CTEST_CMAKE_COMMAND 
  "cmake"
  )

# should ctest wipe the binary tree before running
SET (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY TRUE)

# this is the initial cache to use for the binary tree, be careful to escape
# any quotes inside of this string if you use it
SET (CTEST_INITIAL_CACHE "
// Use Launchers for CDash reporting
CTEST_USE_LAUNCHERS:BOOL=ON
//Command used to build entire project from the command line.
MAKECOMMAND:STRING=/usr/bin/make -i -k -j8
//Name of the build
BUILDNAME:STRING=Ubuntu10.4-64bits-Release-External-ITK4
//Name of the computer/site where compile is being run
SITE:STRING=pc-grizonnetm
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/mnt/dd-2/OTB/trunk/OTB-Data/LargeInput
//Data root
OTB_DATA_ROOT:STRING=/mnt/dd-2/OTB/trunk/OTB-Data
//Compilation options
CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable
//Set up the build options
CMAKE_BUILD_TYPE:STRING=Release
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
OTB_USE_CURL:BOOL=ON
OTB_USE_PQXX:BOOL=OFF
//OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_EXTERNAL_EXPAT:BOOL=ON
USE_FFTWD:BOOL=ON
USE_FFTWF:BOOL=ON
OTB_GL_USE_ACCEL:BOOL=ON 
#External ITK 4
OTB_USE_EXTERNAL_ITK:BOOL=ON
ITK_DIR:STRING=/home/otbtesting/Dashboards/My\ Tests/ITK-build/
//OTB_USE_MAPNIK:BOOL=ON 
//MAPNIK_INCLUDE_DIR:STRING=/usr/include
//MAPNIK_LIBRARY:STRING=/usr/lib/libmapnik.so
//CPack configuration
OTB_USE_CPACK:BOOL=ON
CMAKE_INSTALL_PREFIX:STRING=/home/otbtesting/OTB/tmp
CPACK_BINARY_DEB:BOOL=ON
CPACK_DEBIAN_PACKAGE_ARCHITECTURE:STRING=amd64
//Set GDAL options
GDAL_CONFIG:STRING=/home/grizonnetm/Local/gdal-1.7.1-build/bin/gdal-config
GDAL_INCLUDE_DIR:STRING=/home/grizonnetm/Local/gdal-1.7.1-build/include
GDAL_LIBRARY:STRING=/home/grizonnetm/Local/gdal-1.7.1-build/lib/libgdal.so
OGR_INCLUDE_DIRS:STRING=/home/grizonnetm/Local/gdal-1.7.1-build/include
")

# set any extra envionment varibles here
SET (CTEST_ENVIRONMENT
 "DISPLAY=pc-inglada:101"
)


