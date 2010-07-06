
SET (CTEST_SOURCE_DIRECTORY "$ENV{HOME}/Projets/otb/src/Monteverdi")
SET (CTEST_BINARY_DIRECTORY "$ENV{HOME}/Projets/otb/build/debug/Monteverdi")

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
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Projets/otb/src/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Projets/otb/src/OTB-Data

CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

CMAKE_BUILD_TYPE:STRING=Debug

OTB_DIR:STRING=$ENV{HOME}/Projets/otb/build/debug/OTB
BUILD_TESTING:BOOL=ON
CMAKE_INSTALL_PREFIX:STRING=$ENV{HOME}/Projets/otb/install/Monteverdi-debug

GDALCONFIG_EXECUTABLE:FILEPATH=$ENV{HOME}/Utils/bin/gdal-1.7.2/bin/gdal-config
GDAL_CONFIG:STRING=$ENV{HOME}/Utils/bin/gdal-1.7.2/bin/gdal-config
GDAL_INCLUDE_DIR:STRING=$ENV{HOME}/Utils/bin/gdal-1.7.2/include
GDAL_LIBRARY:STRING=$ENV{HOME}/Utils/bin/gdal-1.7.2/lib/libgdal.so

")

# set any extra envionment varibles here
SET (CTEST_ENVIRONMENT
 "DISPLAY=:0"
)

