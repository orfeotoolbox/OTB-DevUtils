# Client maintainer: julien.malik@c-s.fr
set(ENV{DISPLAY} ":0.0")
set(ENV{CC} "/usr/bin/clang-3.1")
set(ENV{CXX} "/usr/bin/clang++-3.1")

set(dashboard_model Experimental)
set(CTEST_DASHBOARD_ROOT "/home/otbval/Dashboard/experimental")
set(CTEST_SITE "dora.c-s.fr")
set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)
set(CTEST_BUILD_NAME "ITKv4-Ubuntu12.04-64bits-clang31-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Eclipse CDT4 - Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j9 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)

set(CTEST_HG_COMMAND "/usr/bin/hg")
#set(CTEST_HG_UPDATE_OPTIONS "-r otb-itkv4") 

set(dashboard_root_name "tests")
set(dashboard_source_name "src/OTB-ITKv4")
set(dashboard_binary_name "build/OTB-ITKv4-clang31-${CTEST_BUILD_CONFIGURATION}")

set(dashboard_fresh_source_checkout OFF)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-ITKv4")
set(dashboard_hg_branch "default")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wshadow -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON

OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON
OTB_WRAP_QT:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-ITKv4-Data

ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/build/ITKv4-clang31-${CTEST_BUILD_CONFIGURATION}

OTB_USE_DEPRECATED:BOOL=OFF

OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_OPENCV:BOOL=ON
MUPARSERX_LIBRARY:PATH=/home/otbval/Tools/muparserx/install/lib/libmuparserx.so
MUPARSERX_INCLUDE_DIR:PATH=/home/otbval/Tools/muparserx/install/include
    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
