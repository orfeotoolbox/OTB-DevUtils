# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)
set(CTEST_BUILD_NAME "Ubuntu14.04-64bits-${CTEST_BUILD_CONFIGURATION}-3rdPartiesTrunk")
include(${CTEST_SCRIPT_DIRECTORY}/hulk_common.cmake)

set(dashboard_root_name "tests")
set(dashboard_source_name "src/OTB")
set(dashboard_binary_name "build/OTB-3rdPartiesTrunk")

set(OTB_INSTALL_PREFIX ${CTEST_DASHBOARD_ROOT}/install/OTB-3rdPartiesTrunk)

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")

#change to nightly/build_openjpeg_plugin.sh when moving to gdal trunk
set(ENV{LD_LIBRARY_PATH} "${CTEST_DASHBOARD_ROOT}/install/gdal-trunk/lib:${CTEST_DASHBOARD_ROOT}/install/OpenJPEG_v2.0-mangled/lib:$ENV{LD_LIBRARY_PATH}")
set(ENV{GDAL_DATA} "${CTEST_DASHBOARD_ROOT}/src/gdal-trunk/data")
set(ENV{GDAL_DRIVER_PATH} "${CTEST_DASHBOARD_ROOT}/install/gdal-trunk-openjpeg-plugin")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_C_FLAGS:STRING=-fPIC -Wall
CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wno-cpp
CMAKE_INSTALL_PREFIX:PATH=${OTB_INSTALL_PREFIX}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON

OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON
OTB_WRAP_QT:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data

ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/build/ITKv4-upstream-${CTEST_BUILD_CONFIGURATION}

OTB_USE_CURL:BOOL=ON
OTB_USE_LIBKML:BOOL=ON
OTB_USE_LIBSVM:BOOL=ON
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_OPENJPEG:BOOL=ON
OTB_USE_QT4:BOOL=ON

OpenCV_DIR:PATH=/usr/share/OpenCV

OSSIM_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/ossim-dev/include
OSSIM_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/install/ossim-dev/lib/libossim.so

GDAL_INCLUDE_DIR:STRING=${CTEST_DASHBOARD_ROOT}/install/gdal-trunk/include
GDAL_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/install/gdal-trunk/lib/libgdal.so
MUPARSERX_LIBRARY:PATH=${CTEST_DASHBOARD_ROOT}/install/muparserx/lib/libmuparserx.so
MUPARSERX_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/muparserx/include

OpenJPEG_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/OpenJPEG_v2.1/lib/openjpeg-2.1
    ")
endmacro()


SET(CTEST_NOTES_FILES
    "${CTEST_DASHBOARD_ROOT}/nightly/logs/build_gdal_trunk.log"
    "${CTEST_DASHBOARD_ROOT}/nightly/logs/build_ossim_trunk.log")

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
