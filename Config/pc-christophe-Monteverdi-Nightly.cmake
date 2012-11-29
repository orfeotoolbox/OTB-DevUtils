SET (CTEST_SOURCE_DIRECTORY "/home/otbtesting/OTB/trunk/Monteverdi/")
SET (CTEST_BINARY_DIRECTORY "/home/otbtesting/OTB/bin/Monteverdi-Nightly/")


# which ctest command to use for running the dashboard
SET (CTEST_COMMAND 
  "ctest -j3 -D Nightly -A /home/otbtesting/OTB/trunk/OTB-DevUtils/Config/pc-christophe-Monteverdi-Nightly.cmake -V"
  )

# what cmake command to use for configuring this dashboard
SET (CTEST_CMAKE_COMMAND 
  "cmake"
  )
SET (CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k")
# should ctest wipe the binary tree before running
SET (CTEST_START_WITH_EMPTY_BINARY_DIRECTORY TRUE)
SET (CTEST_USE_LAUNCHERS ON)

# this is the initial cache to use for the binary tree, be careful to escape
# any quotes inside of this string if you use it
SET (CTEST_INITIAL_CACHE "
// Use Launchers for CDash reporting
CTEST_USE_LAUNCHERS:BOOL=ON
//Name of the build
BUILDNAME:STRING=Monteverdi-Fedora17-64bits-Release
//Name of the computer/site where compile is being run
SITE:STRING=pc-christophe
//LargeInput
OTB_DATA_USE_LARGEINPUT:BOOL=OFF
//OTB_DATA_LARGEINPUT_ROOT:STRING=/media/ssh/pc-inglada/media/TeraDisk2/LargeInput
//Data root
OTB_DATA_ROOT:STRING=/home/otbtesting/OTB/trunk/OTB-Data
//Compilation options
CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable
//Set up the build options
CMAKE_BUILD_TYPE:STRING=Release
BUILD_TESTING:BOOL=ON
OTB_DIR:STRING=/home/otbtesting/OTB/bin/OTB-Nightly/
")

# set any extra envionment varibles here
SET (CTEST_ENVIRONMENT
 "DISPLAY=:0"
)

