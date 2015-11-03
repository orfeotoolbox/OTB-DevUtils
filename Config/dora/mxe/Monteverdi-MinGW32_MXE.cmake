# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/data/Dashboard")
set(CTEST_SITE "bumblebee.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_USE_LAUNCHERS OFF)
set(CMAKE_CROSSCOMPILING_EMULATOR "/usr/bin/wine")
set(CMAKE_COMMAND "/data/Tools/cmake-git/install/bin/cmake")

set(MXE_ROOT "/data/Tools/mxe")
set(MXE_TARGET_ARCH "i686")
set(PROJECT "monteverdi")

set(dashboard_source_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/build-MinGW-${MXE_TARGET_ARCH}")


set(dashboard_cache "
CMAKE_C_FLAGS:STRING=-Wall -Wshadow -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable
CMAKE_INSTALL_PREFIX:PATH=${CTEST_DASHBOARD_ROOT}/nightly/install-MinGW-${MXE_TARGET_ARCH}
OTB_DIR:PATH=${CTEST_DASHBOARD_ROOT}/nightly/install-MinGW-${MXE_TARGET_ARCH}/lib/cmake/OTB-5.2
BUILD_TESTING:BOOL=ON
ICE_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/nightly/install-MinGW-${MXE_TARGET_ARCH}/include
ICE_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/nightly/install-MinGW-${MXE_TARGET_ARCH}/lib/libOTBIce.dll.a
")

include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)
