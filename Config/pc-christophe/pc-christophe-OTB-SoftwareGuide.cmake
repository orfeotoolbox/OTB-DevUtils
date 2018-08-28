set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting")
set(CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Fedora28-64bits-SoftwareGuide")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_FLAGS "-k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 1)
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_USE_LAUNCHERS OFF)
set(CTEST_GIT_COMMAND "/usr/bin/git")

set(dashboard_root_name "tests")
set(dashboard_source_name "sources/orfeo/trunk/OTB-Nightly/Documentation/SoftwareGuide")
set(dashboard_binary_name "build/orfeo/SoftwareGuide")

set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/sources/orfeo/trunk/OTB-Nightly)

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}
CTEST_USE_LAUNCHERS:BOOL=OFF

BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

CMAKE_C_FLAGS:STRING= -Wall
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-cpp

OTB_DATA_LARGEINPUT_ROOT:STRING=/media/TeraDisk2/LargeInput
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/sources/orfeo/OTB-Data

OTB_DIR:STRING=${CTEST_DASHBOARD_ROOT}/build/orfeo/trunk/OTB-Nightly/Release
OTB_SOURCE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/sources/orfeo/trunk/OTB-Nightly
")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
