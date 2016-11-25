# Client maintainer: julien.malik@c-s.fr
set(OTB_PROJECT Monteverdi2) # OTB / Monteverdi / Monteverdi2 / Ice
set(OTB_ARCH amd64) # x86 / amd64
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_COMMAND  "jom packages")
include(${CTEST_SCRIPT_DIRECTORY}/raoul_common.cmake)
include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)

set(CTEST_BUILD_NAME "Win7-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}-${dashboard_git_branch}")
set(CTEST_INSTALL_PREFIX ${CTEST_DASHBOARD_ROOT}/install/Monteverdi2-stable-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION})
set(dashboard_binary_name "build/Monteverdi2-stable-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_PREFIX}

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

CMAKE_INCLUDE_PATH:PATH=$ENV{OSGEO4W_ROOT}/include
CMAKE_LIBRARY_PATH:PATH=$ENV{OSGEO4W_ROOT}/lib

BUILD_TESTING:BOOL=ON
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:PATH=${CTEST_DASHBOARD_ROOT}/src/OTB-LargeInput

Monteverdi_USE_CPACK:BOOL=ON

OTB_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/OTB-stable-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}/${OTB_STABLE_DIR_SUFFIX}
# ICE_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/Ice-stable-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}/include
# ICE_LIBRARY:PATH=${CTEST_DASHBOARD_ROOT}/install/Ice-stable-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}/lib/OTBIce.lib
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
