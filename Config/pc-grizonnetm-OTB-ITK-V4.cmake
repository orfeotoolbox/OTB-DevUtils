# Client maintainer: manuel.grizonnet@cnes.fr
SET(ENV{DISPLAY} ":0")

set(dashboard_model Experimental)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/Dashboards")
set(CTEST_SITE "pc-grizonnetm")
set(CTEST_BUILD_CONFIGURATION Debug)
set(CTEST_BUILD_NAME "ITKv4-Ubuntu10.04-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Eclipse CDT4 - Unix Makefiles")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_BUILD_COMMAND "/usr/bin/make -j6 -i -k" )

set(CTEST_HG_COMMAND "/usr/bin/hg")
set(CTEST_HG_UPDATE_OPTIONS "-r otb-itkv4") 

set(dashboard_root_name "My\ Tests")
set(dashboard_source_name "My\ Tests/OTB-ITKv4")
set(dashboard_binary_name "My\ Tests/bin/OTB-ITKv4-${CTEST_BUILD_CONFIGURATION}")

set(dashboard_fresh_source_checkout TRUE)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-SandBox")
set(dashboard_hg_branch "otb-itkv4")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

OTB_DATA_USE_LARGEINPUT:BOOL=OFF
OTB_DATA_LARGEINPUT_ROOT:STRING=/mnt/dd-2/OTB/trunk/OTB-Data/LargeInput
OTB_DATA_ROOT:STRING=/mnt/dd-2/OTB/trunk/OTB-Data

CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wshadow -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON

OTB_USE_EXTERNAL_ITK:BOOL=ON
ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/bin/ITKv4-Debug

OTB_USE_CURL:BOOL=ON
OTB_USE_PQXX:BOOL=OFF
OTB_USE_PATENTED:BOOL=OFF
OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_EXTERNAL_EXPAT:BOOL=ON
OTB_USE_EXTERNAL_FLTK:BOOL=ON
USE_FFTWD:BOOL=OFF
USE_FFTWF:BOOL=OFF
OTB_GL_USE_ACCEL:BOOL=OFF
OTB_USE_MAPNIK:BOOL=ON
OTB_USE_VISU_GUI:BOOL=OFF 

    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/otb_common.cmake)
