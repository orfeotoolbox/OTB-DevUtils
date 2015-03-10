SET (ENV{CC} "/opt/local/bin/gcc-mp-4.8")
SET (ENV{CXX} "/opt/local/bin/g++-mp-4.8")

set(CTEST_DASHBOARD_ROOT "$ENV{HOME}/Dashboard")
SET (CTEST_SOURCE_DIRECTORY "/Users/otbval/Dashboard/nightly/OTB-Wrapping/src")
SET (CTEST_BINARY_DIRECTORY "/Users/otbval/Dashboard/nightly/OTB-Wrapping-gcc48/build")
SET( CTEST_CMAKE_GENERATOR  "Unix Makefiles" )
SET (CTEST_CMAKE_COMMAND "cmake" )
SET (CTEST_BUILD_COMMAND "/usr/bin/make -j8 -i -k install" )
SET (CTEST_SITE "leod.c-s.fr")
SET (CTEST_BUILD_NAME "MacOSX10.10-Release-gcc48")
SET (CTEST_BUILD_CONFIGURATION "Release")
SET (CTEST_HG_COMMAND "/opt/local/bin/hg")
SET (CTEST_HG_UPDATE_OPTIONS "-C")
SET (CTEST_USE_LAUNCHERS ON)

SET (CTEST_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CTEST_USE_LAUNCHERS:BOOL=ON

#CMAKE_LIBRARY_PATH:PATH=/opt/local/lib
#CMAKE_INCLUDE_PATH:PATH=/opt/local/include
CMAKE_PREFIX_PATH:PATH=/opt/local

CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable -Wno-gnu -Wno-overloaded-virtual
CMAKE_BUILD_TYPE:STRING=Release

CMAKE_SHARED_LINKER_FLAGS:STRING=-Wl,-no_compact_unwind
CMAKE_MODULE_LINKER_FLAGS:STRING=-Wl,-no_compact_unwind
CMAKE_EXE_LINKER_FLAGS:STRING=-Wl,-no_compact_unwind

CMAKE_INSTALL_PREFIX:STRING=/Users/otbval/Dashboard/nightly/OTB-Wrapping/install

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON

OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON
OTB_WRAP_QT:BOOL=ON

#OTB_DATA_USE_LARGEINPUT:BOOL=ON
#OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data

OTB_USE_CURL:BOOL=ON
OTB_USE_PATENTED:BOOL=OFF
OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_EXTERNAL_EXPAT:BOOL=ON
OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_OPENCV:BOOL=ON
OTB_USE_SIFTFAST:BOOL=OFF

OTB_DIR:STRING=$ENV{HOME}/Dashboard/nightly/OTB-Release-gcc48/build


PYTHON_EXECUTABLE:FILEPATH=/opt/local/bin/python2.7
PYTHON_INCLUDE_DIR:PATH=/opt/local/Library/Frameworks/Python.framework/Versions/2.7/Headers
PYTHON_LIBRARY:FILEPATH=/opt/local/Library/Frameworks/Python.framework/Versions/2.7/Python

ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/itkv4/build

OSSIM_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/ossim/install/include
OSSIM_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/ossim/install/lib64/libossim.dylib

MUPARSERX_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/muparserx/install/include
MUPARSERX_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/muparserx/install/lib/libmuparserx.dylib


# We need the following to be compatible with cmake 2.8.2
JAVA_ARCHIVE:FILEPATH=/usr/bin/jar
JAVA_COMPILE:FILEPATH=/usr/bin/javac
JAVA_RUNTIME:FILEPATH=/usr/bin/java

")

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

ctest_empty_binary_directory (${CTEST_BINARY_DIRECTORY})
ctest_start(Nightly)
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${CTEST_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()

