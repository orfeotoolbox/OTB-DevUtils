# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)

set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/data/dashboard")
set(CTEST_SITE "bumblebee.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_USE_LAUNCHERS ON)
set(CMAKE_COMMAND "/data/tools/cmake-git/install/bin/cmake")
set(CTEST_CMAKE_COMMAND "${CMAKE_COMMAND}")
set(CMAKE_CROSSCOMPILING_EMULATOR "/usr/bin/wine")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k" )
set(CTEST_DASHBOARD_TRACK Examples)
set(MXE_ROOT "/data/tools/mxe")
set(MXE_TARGET_ARCH "i686")
set(PROJECT "otb")

set(CTEST_NIGHTLY_START_TIME "20:00:00 CEST")
set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "dash.orfeo-toolbox.org")
set(CTEST_DROP_LOCATION "/submit.php?project=OTB")
set(CTEST_DROP_SITE_CDASH TRUE)

set(dashboard_update_dir "${CTEST_DASHBOARD_ROOT}/nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_source_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/src/Examples")
set(dashboard_binary_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/build-Examples-MinGW-${MXE_TARGET_ARCH}")

macro(dashboard_hook_init)
set(dashboard_cache "
OTB_DIR:PATH=${CTEST_DASHBOARD_ROOT}/nightly/otb-${CTEST_BUILD_CONFIGURATION}/build-MinGW-${MXE_TARGET_ARCH}
BUILD_TESTING:BOOL=ON
")
endmacro()

set(dashboard_no_test 1)

include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)
