# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)

set(CTEST_DASHBOARD_TRACK Examples)
set(MXE_TARGET_ARCH "i686")
set(PROJECT "otb")

set(dashboard_update_dir "${CTEST_DASHBOARD_ROOT}/nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_source_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/src/Examples")
set(dashboard_binary_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/build-Examples-MinGW-${MXE_TARGET_ARCH}")

macro(dashboard_hook_init)
set(dashboard_cache "

${mxe_common_cache}

BUILD_TESTING:BOOL=ON
")
endmacro()
set(dashboard_make_package OFF)
set(dashboard_no_test 1)

include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)

include(${CTEST_SCRIPT_DIRECTORY}/../../otb_common.cmake)
