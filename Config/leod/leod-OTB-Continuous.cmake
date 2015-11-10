# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Continuous)
set(CTEST_DASHBOARD_ROOT "$ENV{HOME}/Dashboard")
set(CTEST_SITE "leod.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "MacOSX10.10-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_CMAKE_COMMAND "cmake" )
set(CTEST_BUILD_COMMAND "/usr/bin/make -j8 -i -k install" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)

set(CTEST_GIT_COMMAND "/opt/local/bin/git")
set(CTEST_GIT_UPDATE_CUSTOM ${CMAKE_COMMAND} -D GIT_COMMAND:PATH=${CTEST_GIT_COMMAND} -D TESTED_BRANCH:STRING=develop -P ${CTEST_SCRIPT_DIRECTORY}/../git_updater.cmake)

string(TOLOWER ${dashboard_model} lcdashboard_model)

set(CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB/src")
set(CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB/build")

set(ENV{DISPLAY} ":0.0")

set(CTEST_INITIAL_CACHE "
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CTEST_USE_LAUNCHERS:BOOL=ON

#CMAKE_LIBRARY_PATH:PATH=/opt/local/lib
#CMAKE_INCLUDE_PATH:PATH=/opt/local/include
CMAKE_PREFIX_PATH:PATH=/opt/local
  
CMAKE_C_FLAGS:STRING= -fPIC -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -fPIC -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable -Wno-gnu -Wno-overloaded-virtual

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CMAKE_INSTALL_PREFIX:STRING=${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB/install

#CMAKE_OSX_ARCHITECTURES:STRING=i386
OPENTHREADS_CONFIG_HAS_BEEN_RUN_BEFORE:BOOL=ON

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON

OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON
OTB_WRAP_QT:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=OFF
#OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data

ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/itkv4/install/lib/cmake/ITK-4.8

GDAL_CONFIG:PATH=/opt/local/bin/gdal-config
GDAL_CONFIG_CHECKING:BOOL=ON
GDAL_INCLUDE_DIR:PATH=/opt/local/include
GDAL_LIBRARY:PATH=/opt/local/lib/libgdal.dylib

OTB_USE_CURL:BOOL=ON
OTB_USE_LIBKML:BOOL=ON
OTB_USE_LIBSVM:BOOL=ON
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_OPENJPEG:BOOL=ON
OTB_USE_QT4:BOOL=ON

PYTHON_EXECUTABLE:FILEPATH=/opt/local/bin/python2.7
PYTHON_INCLUDE_DIR:PATH=/opt/local/Library/Frameworks/Python.framework/Versions/2.7/Headers
PYTHON_LIBRARY:FILEPATH=/opt/local/Library/Frameworks/Python.framework/Versions/2.7/Python

OSSIM_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/ossim/install/include
OSSIM_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/ossim/install/lib/libossim.dylib

MUPARSER_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/muparser/install/include
MUPARSER_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/muparser/install/lib/libmuparser.dylib

MUPARSERX_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/muparserx/install/include
MUPARSERX_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/muparserx/install/lib/libmuparserx.dylib

LIBSVM_INCLUDE_DIR:PATH=/opt/local/include
LIBSVM_LIBRARY:FILEPATH=/opt/local/lib/libsvm.dylib

")

SET (CTEST_NOTES_FILES
${CTEST_SCRIPT_DIRECTORY}/${CTEST_SCRIPT_NAME}
${CTEST_BINARY_DIRECTORY}/CMakeCache.txt
)

ctest_start(${dashboard_model})
ctest_update(SOURCE "${CTEST_SOURCE_DIRECTORY}" RETURN_VALUE count)
message("Found ${count} changed files")
file(WRITE "${CTEST_BINARY_DIRECTORY}/CMakeCache.txt" ${CTEST_INITIAL_CACHE})
ctest_configure (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_read_custom_files(${CTEST_BINARY_DIRECTORY})
ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
ctest_submit (PARTS Start Update Configure Build)
ctest_test (BUILD "${CTEST_BINARY_DIRECTORY}" PARALLEL_LEVEL 4)
ctest_submit ()
