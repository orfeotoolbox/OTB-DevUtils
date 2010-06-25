SET (CTEST_SOURCE_DIRECTORY "/mnt/dd-2/OTB/trunk/OTB-Wrapping-Nightly/")
SET (CTEST_BINARY_DIRECTORY "/mnt/dd-2/OTB/OTB-Binary-Wrapping-Nightly/")


# which ctest command to use for running the dashboard
SET (CTEST_COMMAND 
  "ctest -j6 -D Nightly -A /mnt/dd-2/OTB/trunk/OTB-DevUtils/Config/pc-grizonnetm-OTB-Wrapping-Nightly.cmake -V"
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
//LargeInput
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/mnt/dd-2/OTB/trunk/OTB-Data/LargeInput
//Compilation options
CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable
//Set up the build options
CMAKE_BUILD_TYPE:STRING=Release
OTB_DIR:STRING=/mnt/dd-2/OTB/OTB-Binary-Nightly
BUILD_TESTING:BOOL=ON
CableSwig_DIR:STRING=/usr/lib/CableSwig
//Set up SWIG options
SWIG_DIR:STRING=/home/otbtesting/local/swig-1.3.40-build/share/swig/1.3.40
SWIG_EXECUTABLE:STRING=/home/otbtesting/local/swig-1.3.40-build/bin/swig
SWIG_VERSION:STRING=1.3.40
WRAP_LevelSet:BOOL=OFF
WRAP_Morphology:BOOL=OFF
WRAP_ChangeDetection:BOOL=OFF
WRAP_ITK_DIMS:STRING=2
WRAP_ITK_JAVA:BOOL=ON 
JAVA_AWT_INCLUDE_PATH:STRING=/usr/lib/jvm/java-6-sun/include
JAVA_AWT_LIBRARY:STRING=/usr/lib/jvm/java-6-sun/jre/lib/amd64
JAVA_INCLUDE_PATH:STRING=/usr/lib/jvm/java-6-sun/include
JAVA_INCLUDE_PATH2:STRING=/usr/lib/jvm/java-6-sun/include/linux
JAVA_JVM_LIBRARY:STRING=/usr/lib/jvm/java-6-sun/jre/lib/amd64/server
WRAP_ITK_PYTHON:BOOL=ON 
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


