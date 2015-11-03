# Client maintainer: julien.malik@c-s.fr
set(OTB_PROJECT Monteverdi) # OTB / Monteverdi / Monteverdi2 / Ice
set(OTB_ARCH x86) # x86 / amd64
set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)
include(${CTEST_SCRIPT_DIRECTORY}/raoul_common.cmake)

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_PREFIX}

BUILD_TESTING:BOOL=ON
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:PATH=${CTEST_DASHBOARD_ROOT}/src/OTB-LargeInput

OTB_USE_CPACK:BOOL=ON

GDAL_INCLUDE_DIR:PATH=C:/OSGeo4W/include
GDAL_LIBRARY:FILEPATH=C:/OSGeo4W/lib/gdal_i.lib

OTB_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/OTB-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}/lib/cmake/OTB-5.2
FLTK_DIR:PATH=C:/OSGeo4W/share/FLTK
OpenCV_DIR:PATH=${CTEST_DASHBOARD_ROOT}/tools/install/opencv-2.4.10-vc10-${OTB_ARCH}/share/OpenCV

")
endmacro()

macro(dashboard_hook_build)
  set(_SAVE_BUILD_COMMAND ${CTEST_BUILD_COMMAND})
  unset(CTEST_BUILD_COMMAND)
  ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}" TARGET PACKAGES)
  set(CTEST_BUILD_COMMAND ${_SAVE_BUILD_COMMAND})
endmacro()

#Remove install dir
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_PREFIX})
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_PREFIX})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
