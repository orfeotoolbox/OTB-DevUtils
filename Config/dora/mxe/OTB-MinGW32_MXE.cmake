# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/data/Dashboard")
set(CTEST_SITE "bumblebee.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(MXE_ROOT "/data/Tools/mxe")
set(MXE_TARGET_ARCH "i686")
set(PROJECT "OTB")
set(dashboard_source_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/build-MinGW-${MXE_TARGET_ARCH}")
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-Nightly")
set(CMAKE_CROSSCOMPILING_EMULATOR "/usr/bin/wine")
set(CTEST_USE_LAUNCHERS ON)

macro(dashboard_hook_init)
set(dashboard_cache "
${otb_cache_common}

OTB_DATA_USE_LARGEINPUT:BOOL=OFF
OTB_DATA_ROOT:STRING=/data/OTB-Data
OTB_DATA_LARGEINPUT_ROOT:STRING=/data/OTB-LargeInput

CMAKE_C_FLAGS:STRING=-Wall -Wshadow -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

#install otb, ice, monteverdi in the same directory for ease of searching dll and exes
CMAKE_INSTALL_PREFIX:PATH=${CTEST_DASHBOARD_ROOT}/nightly/install-MinGW-${MXE_TARGET_ARCH}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=OFF
OTB_WRAP_PYTHON:BOOL=OFF
OTB_WRAP_JAVA:BOOL=OFF
OTB_USE_QT4:BOOL=ON

OTB_USE_OPENCV:BOOL=OFF
OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_SIFTFAST:BOOL=ON
OTB_USE_OPENJPEG:BOOL=OFF
OTB_USE_LIBKML:BOOL=OFF
OTB_USE_LIBSVM:BOOL=OFF

")

endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)
