# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Ubuntu14.04-64bits-SoftwareGuide")
set(CTEST_BUILD_FLAGS "-k" )
include(${CTEST_SCRIPT_DIRECTORY}/hulk_common.cmake)

# peek into ../config_stable.cmake to choose between trunk or stable
file(STRINGS "${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake" _FULL_CONTENT_STABLE)
string(TOUPPER "${_FULL_CONTENT_STABLE}" _FULL_CONTENT_STABLE_UP)
if("${_FULL_CONTENT_STABLE_UP}" MATCHES ".*[^#] *SET *\\( *CONFIG_STABLE_SWITCH +(ON|1|YES|Y|TRUE) *\\).*")
  set(OTB_PROJECT OTB)
  include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)
  unset(OTB_PROJECT)
  set(OTB_DIR $ENV{HOME}/Dashboard/build/OTB-stable)
  set(CTEST_BUILD_NAME "${CTEST_BUILD_NAME}-${OTB_STABLE_VERSION}")
else()
  set(OTB_DIR $ENV{HOME}/Dashboard/build/OTB-GDAL_2.0)
endif()

set(dashboard_root_name "tests")
set(dashboard_source_name "src/OTB/Documentation/SoftwareGuide")
set(dashboard_binary_name "build/SoftwareGuide")

set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/src/OTB)

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}
CTEST_USE_LAUNCHERS:BOOL=OFF

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

CMAKE_C_FLAGS:STRING= -Wall
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-cpp

OTB_DATA_LARGEINPUT_ROOT:STRING=/media/otbnas/otb/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Dashboard/src/OTB-Data

OTB_DIR:STRING=${OTB_DIR}
OTB_SOURCE_DIR:PATH=$ENV{HOME}/Dashboard/src/OTB
")
endmacro()

#set(dashboard_no_test 1)
#set(dashboard_no_submit 1)

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
