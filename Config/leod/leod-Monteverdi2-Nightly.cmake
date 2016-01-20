set(dashboard_model Nightly)
string(TOLOWER ${dashboard_model} lcdashboard_model)

set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "MacOSX10.10-${CTEST_BUILD_CONFIGURATION}")
include(${CTEST_SCRIPT_DIRECTORY}/leod_common.cmake)

set(dashboard_root_name "tests")
set(dashboard_source_name "${lcdashboard_model}/Monteverdi2-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "${lcdashboard_model}/Monteverdi2-${CTEST_BUILD_CONFIGURATION}/build")

set(MVD2_INSTALL_PREFIX $ENV{HOME}/Dashboard/${lcdashboard_model}/Monteverdi2-${CTEST_BUILD_CONFIGURATION}/install)

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/monteverdi2.git")

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

OTB_DIR:STRING=$ENV{HOME}/Dashboard/${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/build

ICE_INCLUDE_DIR:PATH=/Users/otbval/Dashboard/nightly/Ice-Release/src/Code
ICE_LIBRARY:FILEPATH=/Users/otbval/Dashboard/nightly/Ice-Release/build/bin/libOTBIce.dylib

Monteverdi_USE_CPACK:BOOL=ON

")
endmacro()

# Remove install tree
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E remove_directory ${MVD2_INSTALL_PREFIX})
execute_process(COMMAND ${CTEST_CMAKE_COMMAND} -E make_directory ${MVD2_INSTALL_PREFIX})

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
