# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "MacOSX10.10-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_DASHBOARD_TRACK Examples)
set(dashboard_no_install 1)
include(${CTEST_SCRIPT_DIRECTORY}/leod_common.cmake)

string(TOLOWER ${dashboard_model} lcdashboard_model)

set(dashboard_update_dir "${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_source_name "${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/src/Examples")
set(dashboard_binary_name "${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/build-examples")

macro(dashboard_hook_init)
set(dashboard_cache "
CMAKE_CXX_FLAGS:STRING=-std=c++11
BUILD_TESTING:BOOL=ON
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data
OTB_DIR:PATH=${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/build-stable
")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
