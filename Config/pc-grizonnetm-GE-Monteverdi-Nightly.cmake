SET (CTEST_SOURCE_DIRECTORY "/mnt/dd-2/OTB/trunk/GE-Monteverdi-Nightly/")
SET (CTEST_BINARY_DIRECTORY "/mnt/dd-2/OTB/GE-Monteverdi-Binary-Nightly/")


# which ctest command to use for running the dashboard
SET (CTEST_COMMAND 
  "ctest -j6 -D Nightly -A /mnt/dd-2/OTB/trunk/OTB-DevUtils/Config/pc-grizonnetm-GE-Monteverdi-Nightly.cmake -V"
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
MAKECOMMAND:STRING=/usr/bin/make -i -k -j8
//Name of the build
BUILDNAME:STRING=Ubuntu9.10-64bits-Release
//Name of the computer/site where compile is being run
SITE:STRING=pc-grizonnetm
//Data root
OTB_DATA_ROOT:STRING=/mnt/dd-2/OTB/trunk/OTB-Data
//Compilation options
CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable
//Set up the build options
CMAKE_BUILD_TYPE:STRING=Release
Monteverdi_DIR:STRING=/mnt/dd-2/OTB/Monteverdi-Binary-Nightly
BUILD_TESTING:BOOL=ON
//CPack configuration
OTB_USE_CPACK:BOOL=OFF
CMAKE_INSTALL_PREFIX:STRING=/home/otbtesting/OTB/tmp
CPACK_BINARY_DEB:BOOL=ON
CPACK_DEBIAN_PACKAGE_ARCHITECTURE:STRING=amd64
")

# set any extra envionment varibles here
SET (CTEST_ENVIRONMENT
 "DISPLAY=:0"
)

