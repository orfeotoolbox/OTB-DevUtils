# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Ubuntu16.04-64bits-SoftwareGuide")
set(CTEST_BUILD_FLAGS "-k" )
include(${CTEST_SCRIPT_DIRECTORY}/dora_common.cmake)

set(dashboard_otb_source "nightly/OTB-Release/src")
set(dashboard_otb_binary "nightly/OTB-Release/build")

set(dashboard_root_name "tests")
set(dashboard_source_name "${dashboard_otb_source}/Documentation/SoftwareGuide")
set(dashboard_binary_name "nightly/SoftwareGuide/develop")

set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/${dashboard_otb_source})

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}
CTEST_USE_LAUNCHERS:BOOL=OFF

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

CMAKE_C_FLAGS:STRING= -Wall
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-cpp

OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data

OTB_DIR:STRING=${CTEST_DASHBOARD_ROOT}/${dashboard_otb_binary}
OTB_SOURCE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/${dashboard_otb_source}
")
endmacro()

#set(dashboard_no_test 1)
#set(dashboard_no_submit 1)

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
