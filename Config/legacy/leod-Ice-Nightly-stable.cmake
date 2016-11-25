set(dashboard_model Nightly)
set (CTEST_BUILD_CONFIGURATION "Release")
set (CTEST_BUILD_NAME "MacOSX10.10-${CTEST_BUILD_CONFIGURATION}-stable")
include(${CTEST_SCRIPT_DIRECTORY}/leod_common.cmake)

set(dashboard_fresh_source_checkout OFF)
set(dashboard_source_name "nightly/Ice-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "nightly/Ice-${CTEST_BUILD_CONFIGURATION}/build-stable")
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/ice.git")
set(dashboard_git_branch release-0.4)
set (ICE_INSTALL_PREFIX "$ENV{HOME}/Dashboard/nightly/Ice-${CTEST_BUILD_CONFIGURATION}/install-stable")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_C_FLAGS:STRING=-Wall
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-\\\\#warnings

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

OTB_DIR:PATH=/Users/otbval/Dashboard/nightly/OTB-Release/install-stable/lib/cmake/OTB-5.2

#use glut from XQuartz - http://hg.orfeo-toolbox.org/Ice/rev/2686f7776582

GLUT_glut_LIBRARY=/usr/X11R6/lib/libglut.3.dylib
GLUT_INCLUDE_DIR=/usr/X11R6/include

BUILD_TESTING:BOOL=ON
CMAKE_INSTALL_PREFIX:STRING=${ICE_INSTALL_PREFIX}
BUILD_ICE_APPLICATION:BOOL=ON

    ")
endmacro()

macro(dashboard_hook_test)
# before testing, set the DYLD_LIBRARY_PATH
set(ENV{DYLD_LIBRARY_PATH} /Users/otbval/Dashboard/nightly/OTB-Release/install-stable/lib)
endmacro()

execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${ICE_INSTALL_PREFIX})
execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${ICE_INSTALL_PREFIX})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
