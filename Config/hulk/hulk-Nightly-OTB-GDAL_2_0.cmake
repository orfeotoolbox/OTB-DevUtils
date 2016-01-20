# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Debug)
set(CTEST_BUILD_NAME "Ubuntu14.04-64bits-${CTEST_BUILD_CONFIGURATION}-GDAL_2.0")
include(${CTEST_SCRIPT_DIRECTORY}/hulk_common.cmake)

set(dashboard_root_name "tests")
set(dashboard_source_name "src/OTB")
set(dashboard_binary_name "build/OTB-GDAL_2.0")

set(OTB_INSTALL_PREFIX ${CTEST_DASHBOARD_ROOT}/install/OTB-GDAL_2.0)

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_C_FLAGS:STRING=-fPIC -Wall
CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wno-cpp
CMAKE_INSTALL_PREFIX:PATH=${OTB_INSTALL_PREFIX}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON

OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=OFF
OTB_WRAP_QT:BOOL=ON

OTB_SHOW_ALL_MSG_DEBUG:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=OFF
#OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data

GDAL_CONFIG:PATH=${CTEST_DASHBOARD_ROOT}/install/gdal-2.0/bin/gdal-config
GDAL_CONFIG_CHECKING:BOOL=ON
GDAL_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/gdal-2.0/include
GDAL_LIBRARY:PATH=${CTEST_DASHBOARD_ROOT}/install/gdal-2.0/lib/libgdal.so

ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/ITK-4.7.1/lib/cmake/ITK-4.7

OTB_USE_CURL:BOOL=ON
OTB_USE_LIBKML:BOOL=ON
OTB_USE_LIBSVM:BOOL=ON
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_OPENJPEG:BOOL=ON
OTB_USE_QT4:BOOL=ON

OpenCV_DIR:PATH=/usr/share/OpenCV
MUPARSERX_LIBRARY:PATH=${CTEST_DASHBOARD_ROOT}/install/muparserx/lib/libmuparserx.so
MUPARSERX_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/muparserx/include

OpenJPEG_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/OpenJPEG_v2.1/lib/openjpeg-2.1
    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
