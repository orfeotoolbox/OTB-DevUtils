# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbval/Dashboard")
set(CTEST_SITE "dora.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(MXE_ROOT "/home/otbval/Tools/mxe")
set(MXE_TARGET_ARCH "x86_64")
set(PROJECT "OTB")
set(dashboard_source_name "nighlty/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "nighlty/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/build-MinGW-${MXE_TARGET_ARCH}")
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-Nightly")

include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)

macro(dashboard_hook_init)
set(dashboard_cache "
${otb_cache_common}

OTB_DATA_USE_LARGEINPUT:BOOL=OFF
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput

CMAKE_C_FLAGS:STRING=-Wall -Wshadow -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

BUILD_TESTING:BOOL=OFF
BUILD_EXAMPLES:BOOL=OFF
OTB_WRAP_PYTHON:BOOL=OFF
OTB_WRAP_JAVA:BOOL=OFF
OTB_USE_QT4=ON

OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_OPENCV:BOOL=ON
OTB_USE_SIFTFAST:BOOL=OFF
OTB_USE_OPENJPEG:BOOL=OFF
OTB_USE_LIBKML=OFF
OTB_USE_LIBSVM=OFF

CHECK_HDF4OPEN_SYMBOL_EXITCODE:STRING=FAILED_TO_RUN

")
endmacro()

set(dashboard_no_test 1)
