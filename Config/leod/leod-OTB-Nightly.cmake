# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "$ENV{HOME}/Dashboard")
set(CTEST_SITE "leod.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "MacOSX10.10-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_CMAKE_COMMAND "cmake" )
set(CTEST_BUILD_COMMAND "/usr/bin/make -j8 -i -k install" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)

set(CTEST_HG_COMMAND "/opt/local/bin/git")

string(TOLOWER ${dashboard_model} lcdashboard_model)

set(dashboard_root_name "tests")
set(dashboard_source_name "${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/build")

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")
#set(dashboard_hg_branch "default")

set(ENV{DISPLAY} ":0.0")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_INSTALL_PREFIX:PATH=${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/install

CMAKE_PREFIX_PATH:PATH=/opt/local

CMAKE_C_FLAGS:STRING= -fPIC -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -fPIC -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable -Wno-gnu -Wno-overloaded-virtual -Wno-\\\\#warnings

OPENTHREADS_CONFIG_HAS_BEEN_RUN_BEFORE:BOOL=ON

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=OFF

OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON
OTB_WRAP_QT:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data

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

ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/itkv4/install/lib/cmake/ITK-4.8

OSSIM_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/ossim/install/include
OSSIM_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/ossim/install/lib/libossim.dylib

MUPARSERX_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/muparserx/install/include
MUPARSERX_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/muparserx/install/lib/libmuparserx.dylib

LIBSVM_INCLUDE_DIR:PATH=/opt/local/include
LIBSVM_LIBRARY:FILEPATH=/opt/local/lib/libsvm.dylib

    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
