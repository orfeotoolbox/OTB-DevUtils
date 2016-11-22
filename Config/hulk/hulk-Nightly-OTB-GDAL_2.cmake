# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Ubuntu14.04-64bits-${CTEST_BUILD_CONFIGURATION}-GDAL_2")
include(${CTEST_SCRIPT_DIRECTORY}/hulk_common.cmake)

set(dashboard_root_name "tests")
set(dashboard_source_name "src/OTB")
set(dashboard_binary_name "build/OTB-GDAL_2")

set(OTB_INSTALL_PREFIX ${CTEST_DASHBOARD_ROOT}/install/OTB-GDAL_2)

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_C_FLAGS:STRING=-fPIC -Wall
CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wno-cpp
CMAKE_INSTALL_PREFIX:PATH=${OTB_INSTALL_PREFIX}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=OFF

OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=OFF
OTB_WRAP_QT:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=OFF
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data

GDAL_CONFIG:PATH=${CTEST_DASHBOARD_ROOT}/install/gdal-SB/bin/gdal-config
GDAL_CONFIG_CHECKING:BOOL=ON
GDAL_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/gdal-SB/include
GDAL_LIBRARY:PATH=${CTEST_DASHBOARD_ROOT}/install/gdal-SB/lib/libgdal.so

ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/ITK-4.7.1/lib/cmake/ITK-4.7

OTB_USE_CURL:BOOL=ON
OTB_USE_LIBKML:BOOL=ON
OTB_USE_LIBSVM:BOOL=ON
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_QT4:BOOL=ON

# mapnik tests fails with gdal2.0. update mapnik version, test and enable again
# This requires changes Modules/ThirdParty/Mapnik/
OTB_USE_MAPNIK:BOOL=OFF

# MAPNIK_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/mapnik-2.0.0/include
# MAPNIK_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/install/mapnik-2.0.0/lib/libmapnik2.so

OSSIM_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/ossim-1.8.20-3/include
OSSIM_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/install/ossim-1.8.20-3/lib/libossim.so

OpenCV_DIR:PATH=/usr/share/OpenCV
MUPARSERX_LIBRARY:PATH=${CTEST_DASHBOARD_ROOT}/install/muparserx/lib/libmuparserx.so
MUPARSERX_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/muparserx/include


LIBKML_BASE_LIBRARY:PATH=${CTEST_DASHBOARD_ROOT}/install/libkml/lib/libkmlbase.so
LIBKML_CONVENIENCE_LIBRARY:PATH=${CTEST_DASHBOARD_ROOT}/install/libkml/lib/libkmlconvenience.so
LIBKML_DOM_LIBRARY:PATH=${CTEST_DASHBOARD_ROOT}/install/libkml/lib/libkmldom.so
LIBKML_ENGINE_LIBRARY:PATH=${CTEST_DASHBOARD_ROOT}/install/libkml/lib/libkmlengine.so
LIBKML_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/libkml/include
LIBKML_MINIZIP_LIBRARY:PATH=${CTEST_DASHBOARD_ROOT}/install/libkml/lib/libminizip.so
LIBKML_REGIONATOR_LIBRARY:PATH=${CTEST_DASHBOARD_ROOT}/install/libkml/lib/libkmlregionator.so
LIBKML_XSD_LIBRARY:PATH=${CTEST_DASHBOARD_ROOT}/install/libkml/lib/libkmlxsd.so
    ")
endmacro()

set( ENV{GDAL_DATA} ${CTEST_DASHBOARD_ROOT}/install/gdal-SB/share/gdal)
#no epsg_csv direcrtory!
set( ENV{GEOTIFF_CSV} ${CTEST_DASHBOARD_ROOT}/install/gdal-SB/share/epsg_csv)

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
