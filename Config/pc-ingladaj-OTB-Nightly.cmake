
SET (CTEST_SOURCE_DIRECTORY "$ENV{HOME}/OTB/trunk/OTB-Nightly/")
SET (CTEST_BINARY_DIRECTORY "$ENV{HOME}/OTB/OTB-Binary-Nightly/")


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
// Use Launchers for CDash reporting
CTEST_USE_LAUNCHERS:BOOL=ON
//Command used to build entire project from the command line.
MAKECOMMAND:STRING=/usr/bin/make -i -k -j6
//Name of the build
BUILDNAME:STRING=ArchLinux-Release
//Name of the computer/site where compile is being run
SITE:STRING=pc-ingladaj
//Data root
OTB_DATA_ROOT:STRING=$ENV{HOME}/OTB/trunk/OTB-Data
//Set up the build options
CMAKE_BUILD_TYPE:STRING=Release
BUILD_TESTING:BOOL=ON
")

# set any extra envionment varibles here
SET (CTEST_ENVIRONMENT
 "DISPLAY=:101"
)

