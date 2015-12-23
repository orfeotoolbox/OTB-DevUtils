# Client maintainer: julien.malik@c-s.fr
set(OTB_PROJECT Monteverdi2) # OTB / Monteverdi / Monteverdi2 / Ice
set(OTB_ARCH x86) # x86 / amd64
set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)
set(CTEST_BUILD_COMMAND  "jom packages")
include(${CTEST_SCRIPT_DIRECTORY}/raoul_common.cmake)

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}

CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_PREFIX}

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

CMAKE_INCLUDE_PATH:PATH=$ENV{OSGEO4W_ROOT}/include
CMAKE_LIBRARY_PATH:PATH=$ENV{OSGEO4W_ROOT}/lib

BUILD_TESTING:BOOL=ON
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:PATH=${CTEST_DASHBOARD_ROOT}/src/OTB-LargeInput

Monteverdi_USE_CPACK:BOOL=ON

OTB_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/OTB-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}/lib/cmake/OTB-5.3
ICE_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/Ice-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}/include/
ICE_LIBRARY:PATH=${CTEST_DASHBOARD_ROOT}/install/Ice-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}/lib/OTBIce.lib

ICUUC_INCLUDE_DIR:PATH=C:/Program Files (x86)/icu4c-4_2_1-Win32-msvc9/icu/include
ICUUC_LIBRARY:FILEPATH=C:/Program Files (x86)/icu4c-4_2_1-Win32-msvc9/icu/lib/icuuc.lib
LTDL_INCLUDE_DIR:PATH=C:/Program Files (x86)/GnuWin32/include
LTDL_LIBRARY:FILEPATH=C:/Program Files (x86)/GnuWin32/lib/ltdl.lib
")
endmacro()

macro(dashboard_hook_build)
  set(_SAVE_BUILD_COMMAND ${CTEST_BUILD_COMMAND})
  set(CTEST_BUILD_COMMAND "jom")
  ctest_build (BUILD "${CTEST_BINARY_DIRECTORY}")
  set(CTEST_BUILD_COMMAND ${_SAVE_BUILD_COMMAND})
endmacro()

#Remove install dir
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_PREFIX})
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_PREFIX})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
