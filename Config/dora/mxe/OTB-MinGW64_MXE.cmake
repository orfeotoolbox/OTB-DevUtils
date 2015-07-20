# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/data/Dashboard")
set(CTEST_SITE "bumblebee.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_USE_LAUNCHERS ON)
set(CMAKE_COMMAND "/data/Tools/cmake-git/install/bin/cmake")
set(CMAKE_CROSSCOMPILING_EMULATOR "/usr/bin/wine")

set(MXE_ROOT "/data/Tools/mxe")
set(MXE_TARGET_ARCH "x86_64")
set(PROJECT "otb")

set(dashboard_source_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/build-MinGW-${MXE_TARGET_ARCH}")

macro(dashboard_hook_init)
set(dashboard_cache "
${otb_cache_common}

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_ROOT:STRING=/data/OTB-Data
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/otbnas/otb/OTB-LargeInput

CMAKE_C_FLAGS:STRING=-Wall -Wshadow -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

MXE_TARGET_DIR:PATH=${MXE_ROOT}/usr/${MXE_TARGET_ARCH}-w64-mingw32.shared

#install otb, ice, monteverdi in the same directory for ease of searching dll and exes
CMAKE_INSTALL_PREFIX:PATH=${CTEST_DASHBOARD_ROOT}/nightly/install-MinGW-${MXE_TARGET_ARCH}

OTB_USE_OPENJPEG:BOOL=OFF
OTB_USE_MAPNIK:BOOL=OFF

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=OFF
OTB_WRAP_PYTHON:BOOL=OFF
OTB_WRAP_JAVA:BOOL=OFF

OTB_USE_QT4:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_SIFTFAST:BOOL=ON
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_LIBKML:BOOL=OFF
OTB_USE_LIBSVM:BOOL=OFF

IS_X86_64_EXITCODE:INTERNAL=0

")

endmacro()

macro(dashboard_hook_end)
  unset(CTEST_BUILD_COMMAND)
  ctest_build(TARGET "package-mingw")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)
