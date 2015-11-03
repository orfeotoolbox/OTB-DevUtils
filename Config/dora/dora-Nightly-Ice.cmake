####################################
# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbval/Dashboard")
set(CTEST_SITE "dora.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Ubuntu12.04-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j6 -i -k install" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)

set(CTEST_GIT_COMMAND "/usr/bin/git")

set(dashboard_fresh_source_checkout OFF)
set(dashboard_source_name "nightly/Ice/src")
set(dashboard_binary_name "nightly/Ice/build")

set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/ice.git")

set (ICE_INSTALL_PREFIX "/home/otbval/Dashboard/nightly/Ice/install")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_C_FLAGS:STRING= -Wall
CMAKE_CXX_FLAGS:STRING= -Wall

BUILD_TESTING:BOOL=ON

OTB_DIR:PATH=$ENV{HOME}/Dashboard/nightly/OTB-Release/install/lib/cmake/OTB-5.2

CMAKE_INSTALL_PREFIX:STRING=${ICE_INSTALL_PREFIX}

BUILD_ICE_APPLICATION:BOOL=OFF

    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
