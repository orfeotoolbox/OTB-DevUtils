# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Experimental)
set(CTEST_DASHBOARD_ROOT "/home/otbval/Dashboard")
set(CTEST_SITE "hulk.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Debug)
set(CTEST_BUILD_NAME "Ubuntu10.04-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Eclipse CDT4 - Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j6 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)

set(CTEST_HG_COMMAND "/usr/bin/hg")
set(CTEST_HG_UPDATE_OPTIONS "-r otb-itkv4") 

set(dashboard_root_name "tests")
set(dashboard_source_name "src/OTB-ITKv4")
set(dashboard_binary_name "build/OTB-ITKv4-${CTEST_BUILD_CONFIGURATION}")

set(dashboard_fresh_source_checkout TRUE)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-SandBox")
set(dashboard_hg_branch "otb-itkv4")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

OTB_DATA_USE_LARGEINPUT:BOOL=OFF
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/otbnas/otb/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Dashboard/src/OTB-Data

CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wshadow -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON

OTB_USE_EXTERNAL_ITK:BOOL=ON
ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/build/ITKv4-Debug

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

    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/otb_common.cmake)
