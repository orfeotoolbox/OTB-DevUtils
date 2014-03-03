# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Experimental)
set(CTEST_DASHBOARD_ROOT "$ENV{HOME}/Dashboard")
set(CTEST_SITE "leod.c-s.fr")
set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)
set(CTEST_BUILD_NAME "ITKv4-MacOSX10.8-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j9 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)

set(CTEST_HG_COMMAND "/opt/local/bin/hg")

#set(dashboard_root_name "tests")
set(dashboard_source_name "nightly/OTB-ITKv4/src")
set(dashboard_binary_name "nightly/OTB-ITKv4/build")

set(dashboard_fresh_source_checkout OFF)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-ITKv4")
set(dashboard_hg_branch "default")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_LIBRARY_PATH:PATH=/opt/local/lib
CMAKE_INCLUDE_PATH:PATH=/opt/local/include

CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wshadow -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable -Wno-gnu -Wno-overloaded-virtual

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
BUILD_APPLICATIONS:BOOL=ON

OTB_WRAP_PYTHON:BOOL=OFF
OTB_WRAP_JAVA:BOOL=OFF
OTB_WRAP_QT:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data-ITKv4

OTB_USE_EXTERNAL_ITK:BOOL=ON
ITK_DIR:PATH=/Users/otbval/Dashboard/itkv4/build

OPENTHREADS_CONFIG_HAS_BEEN_RUN_BEFORE:BOOL=ON

OTB_USE_CURL:BOOL=ON
OTB_USE_PATENTED:BOOL=OFF
OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_EXTERNAL_EXPAT:BOOL=ON
OTB_USE_MAPNIK:BOOL=OFF

PYTHON_EXECUTABLE:FILEPATH=/opt/local/bin/python
PYTHON_INCLUDE_DIR:PATH=/opt/local/Library/Frameworks/Python.framework/Versions/2.7/Headers
PYTHON_LIBRARY:FILEPATH=/opt/local/Library/Frameworks/Python.framework/Versions/2.7/Python


    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
