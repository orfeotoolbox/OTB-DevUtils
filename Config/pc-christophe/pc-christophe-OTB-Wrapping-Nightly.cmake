SET (CTEST_SOURCE_DIRECTORY "/home/otbtesting/OTB/trunk/OTB-Wrapping/")
SET (CTEST_BINARY_DIRECTORY "/home/otbtesting/OTB/bin/OTB-Binary-Wrapping-Nightly/")


# which ctest command to use for running the dashboard
SET (CTEST_COMMAND 
  "ctest -j6 -D Nightly -A /home/otbtesting/OTB/trunk/OTB-DevUtils/Config/pc-christophe-OTB-Wrapping-Nightly.cmake -V"
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
CTEST_USE_LAUNCHERS:BOOL=1
//Name of the build
BUILDNAME:STRING=Fedora17-64bits-Release
//Name of the computer/site where compile is being run
SITE:STRING=pc-christophe
//Data root
OTB_DATA_ROOT:STRING=/home/otbtesting/OTB/trunk/OTB-Data
//LargeInput
OTB_DATA_USE_LARGEINPUT:BOOL=OFF
//OTB_DATA_LARGEINPUT_ROOT:STRING=/media/ssh/pc-inglada/media/TeraDisk2/LargeInput
//Compilation options
CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable
//Set up the build options
CMAKE_BUILD_TYPE:STRING=Release
OTB_DIR:STRING=/home/otbtesting/OTB/bin/OTB-Nightly/
BUILD_TESTING:BOOL=ON
//CableSwig_DIR:STRING=/usr/local/lib/CableSwig
//Set up SWIG options
//SWIG_DIR:STRING=/home/otbtesting/local/swig-1.3.40-build/share/swig/1.3.40
//SWIG_EXECUTABLE:STRING=/usr/bin/swig
//SWIG_VERSION:STRING=1.3.40
WRAP_LevelSet:BOOL=OFF
WRAP_Morphology:BOOL=OFF
WRAP_ChangeDetection:BOOL=OFF
WRAP_ITK_DIMS:STRING=2
WRAP_ITK_JAVA:BOOL=ON 
WRAP_ITK_PYTHON:BOOL=ON 
// We need the following to be compatible with cmake 2.8.2
//JAVA_ARCHIVE:FILEPATH=/opt/java/bin/jar
//JAVA_COMPILE:FILEPATH=/opt/java/bin/javac
//JAVA_RUNTIME:FILEPATH=/opt/java/bin/java
// Python Excecutable
//PYTHON_EXECUTABLE:FILEPATH=/usr/bin/python2
//JAVA_AWT_INCLUDE_PATH:STRING=/opt/java/include/linux/
//JAVA_AWT_LIBRARY:STRING=/opt/java/jre/lib/amd64/
//JAVA_INCLUDE_PATH:STRING=/opt/java/include/
//JAVA_INCLUDE_PATH2:STRING=/opt/java/include/linux/
//JAVA_JVM_LIBRARY:STRING=/opt/java/jre/lib/amd64/server/	
")

# set any extra envionment varibles here
#SET (CTEST_ENVIRONMENT
# "DISPLAY=pc-inglada:101"
#)



