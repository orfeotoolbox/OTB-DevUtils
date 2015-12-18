# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/data/dashboard")
set(CTEST_SITE "bumblebee.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CMAKE_COMMAND "/data/tools/cmake-git/install/bin/cmake")
set(CMAKE_CROSSCOMPILING_EMULATOR "/usr/bin/wine")
set(CTEST_CMAKE_COMMAND "${CMAKE_COMMAND}")
set(CTEST_USE_LAUNCHERS ON)

set(MXE_ROOT "/data/tools/mxe")
set(MXE_TARGET_ARCH "i686")
set(PROJECT "monteverdi2")

set(dashboard_source_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/build-MinGW-${MXE_TARGET_ARCH}")

macro(dashboard_hook_init)
set(dashboard_cache "
CMAKE_C_FLAGS:STRING=-Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable
BUILD_TESTING:BOOL=ON
MXE_TARGET_DIR:PATH=${MXE_ROOT}/usr/${MXE_TARGET_ARCH}-w64-mingw32.shared
CMAKE_INSTALL_PREFIX:PATH=${CTEST_DASHBOARD_ROOT}/nightly/install-MinGW-${MXE_TARGET_ARCH}
OTB_DIR:PATH=${CTEST_DASHBOARD_ROOT}/nightly/install-MinGW-${MXE_TARGET_ARCH}/lib/cmake/OTB-5.2
ICE_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/nightly/install-MinGW-${MXE_TARGET_ARCH}/include
ICE_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/nightly/install-MinGW-${MXE_TARGET_ARCH}/lib/libOTBIce.dll.a
")
endmacro()

macro(dashboard_hook_end)
  unset(CTEST_BUILD_COMMAND)
  ctest_build(TARGET "packages")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)
