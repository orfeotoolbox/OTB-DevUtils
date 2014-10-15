# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbval/Dashboard")
set(CTEST_SITE "hulk.c-s.fr")
set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)
set(CTEST_BUILD_NAME "Ubuntu14.04-64bits-${CTEST_BUILD_CONFIGURATION}-3rdPartiesTrunk")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j9 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)

set(CTEST_HG_COMMAND "/usr/bin/hg")

set(dashboard_root_name "tests")
set(dashboard_source_name "src/OTB")
set(dashboard_binary_name "build/OTB-3rdPartiesTrunk")

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-Nightly")
set(dashboard_hg_branch "default")

set(ENV{DISPLAY} ":0.0")
set(ENV{LD_LIBRARY_PATH} "${CTEST_DASHBOARD_ROOT}/install/gdal-trunk/lib:${CTEST_DASHBOARD_ROOT}/install/OpenJPEG_v2.0-mangled/lib:$ENV{LD_LIBRARY_PATH}")
set(ENV{GDAL_DATA} "${CTEST_DASHBOARD_ROOT}/src/gdal-trunk/data")
set(ENV{GDAL_DRIVER_PATH} "${CTEST_DASHBOARD_ROOT}/install/gdal-openjpeg-plugin")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}
  
CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wshadow -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
BUILD_APPLICATIONS:BOOL=ON
BUILD_BUG_TRACKER_TESTS:BOOL=OFF

OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON
OTB_WRAP_QT:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data

OTB_USE_EXTERNAL_ITK:BOOL=ON
ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/build/ITKv4-upstream-${CTEST_BUILD_CONFIGURATION}

OTB_USE_CURL:BOOL=ON
OTB_USE_PATENTED:BOOL=OFF
#Set OTB_USE_EXTERNAL_BOOST:BOOL to OFF in order to build the OTB with the internal 1.49 Boost library
OTB_USE_EXTERNAL_BOOST:BOOL=OFF
#OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_EXTERNAL_EXPAT:BOOL=ON
OTB_USE_JPEG2000:BOOL=OFF
OTB_USE_JPEG2000_TESTING:BOOL=ON
OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_OPENCV:BOOL=ON
OpenCV_DIR:PATH=/usr/share/OpenCV

OTB_USE_EXTERNAL_OSSIM:BOOL=ON
OSSIM_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/ossim-trunk/include
OSSIM_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/install/ossim-trunk/lib/libossim.so

GDAL_INCLUDE_DIR:STRING=${CTEST_DASHBOARD_ROOT}/install/gdal-trunk/include
GDAL_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/install/gdal-trunk/lib/libgdal.so
    ")
endmacro()


SET(CTEST_NOTES_FILES
    "${CTEST_DASHBOARD_ROOT}/nightly/logs/build_gdal_trunk.log"
    "${CTEST_DASHBOARD_ROOT}/nightly/logs/build_ossim_trunk.log")

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
