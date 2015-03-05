# Client maintainer: julien.malik@c-s.fr
set(OTB_PROJECT OTB) # OTB / Monteverdi / Monteverdi2
set(OTB_ARCH amd64) # x86 / amd64
set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)
set(CTEST_BUILD_TARGET INSTALL)
include(${CTEST_SCRIPT_DIRECTORY}/raoul_common.cmake)

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}
  
CMAKE_INSTALL_PREFIX:PATH=${CTEST_DASHBOARD_ROOT}/install/${OTB_PROJECT}-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON

OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON
OTB_WRAP_QT:BOOL=ON

OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:PATH=${CTEST_DASHBOARD_ROOT}/src/OTB-LargeInput

CMAKE_PREFIX_PATH:PATH=${OSGEO4W_ROOT}

OTB_USE_MAPNIK:BOOL=OFF

OTB_USE_OPENCV:BOOL=ON
OpenCV_DIR:PATH=${OSGEO4W_ROOT}/share/OpenCV

ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/ITK-64-RelDeb/lib/cmake/ITK-4.5

SWIG_EXECUTABLE:FILEPATH=${OSGEO4W_ROOT}/apps/swigwin/swig.exe

PYTHON_EXECUTABLE:FILEPATH=${OSGEO4W_ROOT}/bin/python.exe
PYTHON_INCLUDE_DIR:PATH=${OSGEO4W_ROOT}/apps/Python27/include
PYTHON_LIBRARY:FILEPATH=${OSGEO4W_ROOT}/apps/Python27/libs/python27.lib

TINYXML_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/tools/install/tinyxml-2.6.2-vc10-${OTB_ARCH}/include
TINYXML_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/tools/install/tinyxml-2.6.2-vc10-${OTB_ARCH}/lib/tinyxml.lib

MUPARSERX_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/tools/install/muparserx-vc10-${OTB_ARCH}/include
MUPARSERX_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/tools/install/muparserx-vc10-${OTB_ARCH}/lib/muparserx.lib

LIBKML_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/tools/install/libkml-1.3.0-vc10-${OTB_ARCH}/include
LIBKML_BASE_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/tools/install/libkml-1.3.0-vc10-${OTB_ARCH}/lib/kmlbase.lib
LIBKML_CONVENIENCE_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/tools/install/libkml-1.3.0-vc10-${OTB_ARCH}/lib/kmlconvenience.lib
LIBKML_DOM_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/tools/install/libkml-1.3.0-vc10-${OTB_ARCH}/lib/kmldom.lib
LIBKML_ENGINE_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/tools/install/libkml-1.3.0-vc10-${OTB_ARCH}/lib/kmlengine.lib
LIBKML_MINIZIP_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/tools/install/libkml-1.3.0-vc10-${OTB_ARCH}/lib/minizip.lib
LIBKML_REGIONATOR_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/tools/install/libkml-1.3.0-vc10-${OTB_ARCH}/lib/kmlregionator.lib
LIBKML_XSD_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/tools/install/libkml-1.3.0-vc10-${OTB_ARCH}/lib/kmlxsd.lib

MUPARSER_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/tools/install/muparser-2.2.3-vc10-${OTB_ARCH}/include
MUPARSER_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/tools/install/muparser-2.2.3-vc10-${OTB_ARCH}/lib/muparser.lib

Boost_INCLUDE_DIR:PATH=C:/Program\ Files\ (x86)/boost/boost_1_50
Boost_LIBRARY_DIR:PATH=C:/Program\ Files\ (x86)/boost/boost_1_50/lib64

    ")
endmacro()

#remove install dir
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${CTEST_DASHBOARD_ROOT}/install/${OTB_PROJECT}-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
