# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/data/Dashboard")
set(CTEST_SITE "bumblebee.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CMAKE_CROSSCOMPILING_EMULATOR "/usr/bin/wine")
set(CMAKE_COMMAND "/data/Tools/cmake-git/install/bin/cmake")

set(MXE_ROOT "/data/Tools/mxe")
set(MXE_TARGET_ARCH "i686")
set(PROJECT "monteverdi2")

set(dashboard_source_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/build-MinGW-${MXE_TARGET_ARCH}")

set(dashboard_cache "
CMAKE_C_FLAGS:STRING=-Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable
BUILD_TESTING:BOOL=ON
MXE_TARGET_DIR:PATH=${MXE_ROOT}/usr/${MXE_TARGET_ARCH}-w64-mingw32.shared
CMAKE_INSTALL_PREFIX:PATH=${CTEST_DASHBOARD_ROOT}/nightly/install-MinGW-${MXE_TARGET_ARCH}
OTB_DIR:PATH=${CTEST_DASHBOARD_ROOT}/nightly/install-MinGW-${MXE_TARGET_ARCH}/lib/cmake/OTB-5.0
ICE_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/nightly/install-MinGW-${MXE_TARGET_ARCH}/include
ICE_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/nightly/install-MinGW-${MXE_TARGET_ARCH}/lib/libOTBIce.dll.a
")

macro(dashboard_hook_end)
  unset(CTEST_BUILD_COMMAND)
  ctest_build(TARGET "package-mingw")
endmacro()


include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)
