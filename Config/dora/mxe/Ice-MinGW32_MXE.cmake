# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbval/Dashboard")
set(CTEST_SITE "dora.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(MXE_ROOT "/home/otbval/Tools/mxe")
set(MXE_TARGET_ARCH "i686")
set(PROJECT "Ice")
set(dashboard_source_name "src/Ice")
set(dashboard_binary_name "build/${PROJECT}-${MXE_TARGET_ARCH}-MXE")

include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)

macro(dashboard_hook_init)
set(dashboard_cache "${dashboard_cache}

CMAKE_C_FLAGS:STRING=-Wall

CMAKE_CXX_FLAGS:STRING=-Wall

BUILD_TESTING:BOOL=OFF

BUILD_ICE_APPLICATION:BOOL=ON

")
endmacro()

set(dashboard_no_test 1)


