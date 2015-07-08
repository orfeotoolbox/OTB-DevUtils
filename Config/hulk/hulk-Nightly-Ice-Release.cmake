# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbval/Dashboard")
set(CTEST_SITE "hulk.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Ubuntu14.04-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j9 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 6)
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_USE_LAUNCHERS ON)
set(CTEST_GIT_COMMAND "/usr/bin/git")

set(dashboard_root_name "tests")
set(dashboard_source_name "src/Ice")
set(dashboard_binary_name "build/Ice-${CTEST_BUILD_CONFIGURATION}")

set(ICE_INSTALL_PREFIX ${CTEST_DASHBOARD_ROOT}/install/Ice-${CTEST_BUILD_CONFIGURATION})

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/ice.git")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}

CMAKE_C_FLAGS:STRING=-Wall
CMAKE_CXX_FLAGS:STRING=-Wall

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

OTB_DIR:PATH=/home/otbval/Dashboard/build/OTB-RelWithDebInfo
OpenCV_DIR:PATH=/usr/share/OpenCV 

BUILD_TESTING:BOOL=ON
CMAKE_INSTALL_PREFIX:STRING=${ICE_INSTALL_PREFIX}

BUILD_ICE_APPLICATION:BOOL=OFF
")
endmacro()

execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${ICE_INSTALL_PREFIX})
execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${ICE_INSTALL_PREFIX})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common-git.cmake)
