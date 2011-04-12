
SET (CTEST_SOURCE_DIRECTORY "/mnt/dd-2/OTB/trunk/OTB-Applications-Nightly/")
SET (CTEST_BINARY_DIRECTORY "/mnt/dd-2/OTB/OTB-Binary-Applications-Coverage/")


# which ctest command to use for running the dashboard
SET (CTEST_COMMAND 
  "ctest -j4 -D Nightly -A /mnt/dd-2/OTB/trunk/OTB-DevUtils/Config/pc-grizonnetm-OTB-Applications-Coverage.cmake -V"
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
MAKECOMMAND:STRING=/usr/bin/make -i -k -j6
//Name of the build
BUILDNAME:STRING=zApps-Ubuntu10.4-64bits-Debug
//Name of the computer/site where compile is being run
SITE:STRING=pc-grizonnetm
//Data root
OTB_DATA_ROOT:STRING=/mnt/dd-2/OTB/trunk/OTB-Data
//LargeInput
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/mnt/dd-2/OTB/trunk/OTB-Data/LargeInput
//Compilation options
CMAKE_C_FLAGS:STRING= -Wall -fprofile-arcs -ftest-coverage
CMAKE_CXX_FLAGS:STRING= -Wall -fprofile-arcs -ftest-coverage
CMAKE_EXE_LINKER:STRING= -fprofile-arcs -ftest-coverage
//Set up the build options
CMAKE_BUILD_TYPE:STRING=Debug
OTB_DIR:STRING=/mnt/dd-2/OTB/OTB-Binary-Coverage
BUILD_TESTING:BOOL=ON
OTB_USE_VTK:BOOL=ON
")

# set any extra envionment varibles here
SET (CTEST_ENVIRONMENT
 "DISPLAY=:101"
)

