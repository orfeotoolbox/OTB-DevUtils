# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Debug)
set(CTEST_BUILD_NAME "Ubuntu14.04-64bits-${CTEST_BUILD_CONFIGURATION}")
include(${CTEST_SCRIPT_DIRECTORY}/hulk_common.cmake)

set(dashboard_root_name "tests")
set(dashboard_source_name "src/Ice")
set(dashboard_binary_name "build/Ice-${CTEST_BUILD_CONFIGURATION}")

set(ICE_INSTALL_PREFIX ${CTEST_DASHBOARD_ROOT}/install/Ice-${CTEST_BUILD_CONFIGURATION})

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/ice.git")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}
CMAKE_C_FLAGS:STRING=-Wall
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-cpp

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

OTB_DIR:PATH=/home/otbval/Dashboard/build/OTB-Debug-Coverage
OpenCV_DIR:PATH=/usr/share/OpenCV

BUILD_TESTING:BOOL=ON
CMAKE_INSTALL_PREFIX:STRING=${ICE_INSTALL_PREFIX}

BUILD_ICE_APPLICATION:BOOL=OFF
")
endmacro()

execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${ICE_INSTALL_PREFIX})
execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${ICE_INSTALL_PREFIX})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
