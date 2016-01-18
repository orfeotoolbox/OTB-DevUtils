SET (ENV{DISPLAY} ":0.0")
set (ENV{LANG} "C")

SET (dashboard_model Nightly)
string(TOLOWER ${dashboard_model} lcdashboard_model)

set (CTEST_DASHBOARD_ROOT "$ENV{HOME}/Dashboard")
SET (CTEST_BUILD_CONFIGURATION Release)
SET( CTEST_CMAKE_GENERATOR  "Unix Makefiles" )
SET (CTEST_CMAKE_COMMAND "cmake" )
SET (CTEST_BUILD_COMMAND "/usr/bin/make -j8 -i -k install" )
SET (CTEST_SITE "leod.c-s.fr")
SET (CTEST_BUILD_NAME "MacOSX10.10-${CTEST_BUILD_CONFIGURATION}-stable")
SET (CTEST_GIT_COMMAND "/opt/local/bin/git")
SET (CTEST_USE_LAUNCHERS ON)

set(dashboard_root_name "tests")
set(dashboard_source_name "${lcdashboard_model}/Monteverdi2-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "${lcdashboard_model}/Monteverdi2-${CTEST_BUILD_CONFIGURATION}/build-stable")

set (MVD2_INSTALL_PREFIX $ENV{HOME}/Dashboard/${lcdashboard_model}/Monteverdi2-${CTEST_BUILD_CONFIGURATION}/install-stable)

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/monteverdi2.git")
set(dashboard_git_branch release-3.0)

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_LIBRARY_PATH:PATH=/opt/local/lib
CMAKE_INCLUDE_PATH:PATH=/opt/local/include

BUILD_SHARED_LIBS:BOOL=OFF
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
BUILD_TESTING:BOOL=ON
CMAKE_INSTALL_PREFIX:STRING=${MVD2_INSTALL_PREFIX}

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data

CMAKE_C_FLAGS:STRING= -Wall
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-gnu -Wno-\\\\#warnings

OTB_DIR:STRING=$ENV{HOME}/Dashboard/nightly/OTB-Release/install-stable/lib/cmake/OTB-5.2

ICE_INCLUDE_DIR:PATH=/Users/otbval/Dashboard/nightly/Ice-Release/install-stable/include
ICE_LIBRARY:FILEPATH=/Users/otbval/Dashboard/nightly/Ice-Release/install-stable/lib/libOTBIce.dylib

Monteverdi_USE_CPACK:BOOL=ON

")
endmacro()

# Remove install tree
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${MVD2_INSTALL_PREFIX})
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${MVD2_INSTALL_PREFIX})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
