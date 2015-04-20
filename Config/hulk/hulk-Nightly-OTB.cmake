# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbval/Dashboard")
set(CTEST_SITE "hulk.c-s.fr")
set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)
set(CTEST_BUILD_NAME "Ubuntu14.04-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j9 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)

set(CTEST_HG_COMMAND "/usr/bin/hg")
set(CTEST_HG_UPDATE_OPTIONS "-C")

set(dashboard_root_name "tests")
set(dashboard_source_name "src/OTB")
set(dashboard_binary_name "build/OTB-${CTEST_BUILD_CONFIGURATION}")

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-Nightly")
set(dashboard_hg_branch "default")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}
  
CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wshadow -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
BUILD_DOCUMENTATION:BOOL=ON

OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON
OTB_WRAP_QT:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data

ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/ITK-4.7.1/lib/cmake/ITK-4.7

OTB_USE_MAPNIK:BOOL=ON
MAPNIK_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/mapnik-2.0.0/include
MAPNIK_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/install/mapnik-2.0.0/lib/libmapnik2.so.2.0

OTB_USE_OPENCV:BOOL=ON
OpenCV_DIR:PATH=/usr/share/OpenCV
MUPARSERX_LIBRARY:PATH=${CTEST_DASHBOARD_ROOT}/install/muparserx/lib/libmuparserx.so
MUPARSERX_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/muparserx/include

OTB_DOXYGEN_ITK_TAGFILE:FILEPATH=${CTEST_DASHBOARD_ROOT}/src/InsightDoxygenDocTag-4.6.0
OTB_DOXYGEN_ITK_DOXYGEN_URL:STRING=\"http://www.itk.org/Doxygen46/html\"

OpenJPEG_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/OpenJPEG_v2.1/lib/openjpeg-2.1
    ")
endmacro()

macro(dashboard_hook_end)
  unset(CTEST_BUILD_COMMAND)
  ctest_build(TARGET "Documentation")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
