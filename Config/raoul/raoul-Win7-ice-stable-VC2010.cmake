# Client maintainer: julien.malik@c-s.fr
set(OTB_PROJECT Ice) # OTB / Monteverdi / Monteverdi2 / Ice
set(OTB_ARCH x86) # x86 / amd64
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_TARGET INSTALL)
include(${CTEST_SCRIPT_DIRECTORY}/raoul_common.cmake)

set(CTEST_INSTALL_PREFIX ${CTEST_DASHBOARD_ROOT}/install/Ice-stable-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION})
set(dashboard_git_branch release-0.4)

macro(dashboard_hook_init)
set(dashboard_cache "${dashboard_cache}

CMAKE_INSTALL_PREFIX:PATH=${CTEST_INSTALL_PREFIX}
CMAKE_INCLUDE_PATH:PATH=$ENV{OSGEO4W_ROOT}/include
CMAKE_LIBRARY_PATH:PATH=$ENV{OSGEO4W_ROOT}/lib
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
OTB_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/OTB-stable-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}/lib/cmake/OTB-5.2
")
endmacro()

#remove install dir
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${CTEST_INSTALL_PREFIX})
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${CTEST_INSTALL_PREFIX})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
