set (ENV{DISPLAY} ":0.0")
set (ENV{LANG} "C")

set (dashboard_model Nightly)

set (CTEST_DASHBOARD_ROOT "/home/otbval/Dashboard")
set (CTEST_BUILD_CONFIGURATION Release)
set (CTEST_CMAKE_GENERATOR  "Unix Makefiles")
set (CTEST_CMAKE_COMMAND "cmake" )
set (CTEST_BUILD_COMMAND "/usr/bin/make -j8 -i -k install" )
set (CTEST_SITE "dora.c-s.fr" )
set (CTEST_BUILD_NAME "Ubuntu12.04-64bits-${CTEST_BUILD_CONFIGURATION}")
set (CTEST_HG_COMMAND "/usr/bin/git")
set (CTEST_USE_LAUNCHERS ON)

string(TOLOWER ${dashboard_model} lcdashboard_model)

set(dashboard_root_name "tests")
set(dashboard_source_name "${lcdashboard_model}/Monteverdi2-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "${lcdashboard_model}/Monteverdi2-${CTEST_BUILD_CONFIGURATION}/build")

set (MVD2_INSTALL_PREFIX $ENV{HOME}/Dashboard/${lcdashboard_model}/Monteverdi2-${CTEST_BUILD_CONFIGURATION}/install/)

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/monteverdi2.git")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data

CMAKE_C_FLAGS:STRING=-Wall
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-cpp

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

OTB_DIR:PATH=$ENV{HOME}/Dashboard/${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/install/lib/cmake/OTB-5.2

BUILD_TESTING:BOOL=ON

ICE_INCLUDE_DIR=$ENV{HOME}/Dashboard/nightly/Ice/install/include
ICE_LIBRARY=$ENV{HOME}/Dashboard/nightly/Ice/install/lib/libOTBIce.so

CMAKE_INSTALL_PREFIX:STRING=${MVD2_INSTALL_PREFIX}
")
endmacro()

execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${MVD2_INSTALL_PREFIX})
execute_process (COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${MVD2_INSTALL_PREFIX})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
