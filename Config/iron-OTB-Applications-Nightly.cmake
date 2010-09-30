
SET (CTEST_SOURCE_DIRECTORY "$ENV{HOME}/OTB/trunk/OTB-Applications-Nightly/")
SET (CTEST_BINARY_DIRECTORY "$ENV{HOME}/OTB/OTB-Binary-Applications-Nightly/")


# which ctest command to use for running the dashboard
SET (CTEST_COMMAND 
  "ctest -j6 -D Nightly -A ${CTEST_BINARY_DIRECTORY}/CMakeCache.txt -V"
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
//Command used to build entire project from the command line.
MAKECOMMAND:STRING=/usr/bin/make -i -k -j4
//Name of the build
BUILDNAME:STRING=zApps-Deb51-64bits-Release
//Name of the computer/site where compile is being run
SITE:STRING=iron
//Data root
OTB_DATA_ROOT:STRING=/home/otbtesting/OTB/trunk/OTB-Data
//Compilation options
CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable
//Set up the build options
CMAKE_BUILD_TYPE:STRING=Release
OTB_DIR:STRING=/home/otbtesting/OTB/OTB-Binary-Nightly
BUILD_TESTING:BOOL=ON
//CPack configuration
OTB_USE_CPACK:BOOL=ON
CMAKE_INSTALL_PREFIX:STRING=/home/otbtesting/OTB/tmp
CPACK_BINARY_DEB:BOOL=ON
CPACK_DEBIAN_PACKAGE_ARCHITECTURE:STRING=amd64
")

# set any extra envionment varibles here
SET (CTEST_ENVIRONMENT
 "DISPLAY=:0"
)

