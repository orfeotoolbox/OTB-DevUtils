# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Experimental)
set(CTEST_DASHBOARD_ROOT "C:/Users/jmalik/Dashboard")
set(CTEST_SITE "raoul.c-s.fr")
set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)
set(CTEST_BUILD_NAME "ITKv4-Win7-vc10-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Visual Studio 10")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_CMAKE_COMMAND "C:/Program Files (x86)/CMake 2.8/bin/cmake.exe")

set(CTEST_HG_COMMAND "C:/Program Files (x86)/Mercurial/hg.exe")

set(dashboard_root_name "tests")
set(dashboard_source_name "src/OTB-ITKv4")
set(dashboard_binary_name "build/OTB-ITKv4-VC2010-${CTEST_BUILD_CONFIGURATION}")

set(dashboard_fresh_source_checkout ON)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-ITKv4")
set(dashboard_hg_branch "default")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
BUILD_APPLICATIONS:BOOL=ON

OTB_WRAP_PYTHON:BOOL=OFF
OTB_WRAP_QT:BOOL=ON

OTB_DATA_ROOT:STRING=C:/Users/jmalik/Dashboard/src/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=OFF
OTB_DATA_LARGEINPUT_ROOT:PATH=C:/Users/jmalik/Dashboard/src/OTB-LargeInput

OTB_USE_EXTERNAL_OSSIM:BOOL=ON

OTB_USE_CURL:BOOL=ON
OTB_USE_EXTERNAL_EXPAT:BOOL=ON
#MSD: for the moment we deactivate the build of JPEG2000ImageIO to avoid mangling 
# problem already solved into the OTB trunk
OTB_USE_JPEG2000:BOOL=OFF

OTB_USE_EXTERNAL_ITK:BOOL=ON
ITK_DIR:PATH=C:/Users/jmalik/Dashboard/build/ITKv4-RelDeb

    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
