#compilation command
# ctest -S /mnt/dd-2/OTB/trunk/OTB-DevUtils/Config/pc-grizonnetm-OTB-Clang-Experimental.cmake
SET (CTEST_SOURCE_DIRECTORY "/mnt/dd-2/OTB/trunk/OTB-Experimental/")
SET (CTEST_BINARY_DIRECTORY "/mnt/dd-2/OTB/OTB-Binary-Clang-Experimental/")


# which ctest command to use for running the dashboard
SET (CTEST_COMMAND 
  "ctest -j6 -D Experimental -A /mnt/dd-2/OTB/trunk/OTB-DevUtils/Config/pc-grizonnetm-OTB-Clang-Experimental.cmake -V"
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
CMAKE_CXX_COMPILER:STRING=/usr/local/bin/clang++
// Use Launchers for CDash reporting
CTEST_USE_LAUNCHERS:BOOL=ON
//Command used to build entire project from the command line.
MAKECOMMAND:STRING=/usr/bin/make -i -k -j8
//Name of the build
BUILDNAME:STRING=CLang-Ubuntu10.4-64bits
//Name of the computer/site where compile is being run
SITE:STRING=pc-grizonnetm
//LargeInput
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/mnt/dd-2/OTB/trunk/OTB-Data/LargeInput
//Data root
OTB_DATA_ROOT:STRING=/mnt/dd-2/OTB/trunk/OTB-Data
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
//build applications
BUILD_APPLICATIONS:BOOL=ON
WRAP_PYTHON:BOOL=ON
WRAP_QT:BOOL=ON
WRAP_PYQT:BOOL=ON
")

# set any extra envionment varibles here
#SET (CTEST_ENVIRONMENT
# "DISPLAY=:0"
#)


