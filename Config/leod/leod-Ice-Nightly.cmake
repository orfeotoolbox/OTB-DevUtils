set (ENV{DISPLAY} ":0.0")
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbval/Dashboard")
set (CTEST_BUILD_CONFIGURATION "Release")
set (CTEST_CMAKE_GENERATOR  "Unix Makefiles")
set (CTEST_CMAKE_COMMAND "cmake" )
set (CTEST_BUILD_COMMAND "/usr/bin/make -j8 -i -k install" )
set (CTEST_SITE "leod.c-s.fr" )
set (CTEST_BUILD_NAME "MacOSX10.10-${CTEST_BUILD_CONFIGURATION}")

set (CTEST_GIT_COMMAND "/opt/local/bin/git")

set(dashboard_fresh_source_checkout OFF)
set(dashboard_source_name "nightly/Ice-${CTEST_BUILD_CONFIGURATION}/src-git")
set(dashboard_binary_name "nightly/Ice-${CTEST_BUILD_CONFIGURATION}/build-git")
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/ice.git")

set (ICE_INSTALL_PREFIX "$ENV{HOME}/Dashboard/nightly/Ice-${CTEST_BUILD_CONFIGURATION}/install-git")


macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_C_FLAGS:STRING=-Wall
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-\\\\#warnings

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

OTB_DIR:PATH=/Users/otbval/Dashboard/nightly/OTB-Release/build

#use glut from XQuartz - http://hg.orfeo-toolbox.org/Ice/rev/2686f7776582

GLUT_glut_LIBRARY=/usr/X11R6/lib/libglut.3.dylib
GLUT_INCLUDE_DIR=/usr/X11R6/include

BUILD_TESTING:BOOL=ON
CMAKE_INSTALL_PREFIX:STRING=${ICE_INSTALL_PREFIX}
BUILD_ICE_APPLICATION:BOOL=ON

    ")
endmacro()

execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${ICE_INSTALL_PREFIX})
execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${ICE_INSTALL_PREFIX})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
