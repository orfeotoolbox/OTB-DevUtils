# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbval/Dashboard")
set(CTEST_SITE "dora.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(MXE_ROOT "/home/otbval/Tools/mxe")
set(MXE_TARGET_ARCH "i686")
set(PROJECT "Monteverdi2")
set(dashboard_source_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/build-MinGW-${MXE_TARGET_ARCH}")

macro(dashboard_hook_init)
set(dashboard_cache "${dashboard_cache}

CMAKE_C_FLAGS:STRING=-Wall -Wno-uninitialized -Wno-unused-variable

CMAKE_CXX_FLAGS:STRING=-Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

BUILD_TESTING:BOOL=OFF

")

endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)