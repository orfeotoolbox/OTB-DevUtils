# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)
set(CTEST_SITE "bumblebee.c-s.fr")
set(MXE_TARGET_ARCH "x86_64")
set(PROJECT "otb")

set(dashboard_git_branch "release-5.2")

set(CTEST_TEST_ARGS INCLUDE Tu)

#set(dashboard_source_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/src")
#set(dashboard_binary_name "nightly/${PROJECT}-${CTEST_BUILD_CONFIGURATION}/build-MinGW-${MXE_TARGET_ARCH}")

macro(dashboard_hook_init)
set(dashboard_cache "
OTB_DATA_USE_LARGEINPUT:BOOL=OFF
OTB_DATA_ROOT:STRING=/data/otb-data
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/otbnas/otb/OTB-LargeInput
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=OFF

OTB_USE_CURL:BOOL=ON
OTB_USE_QT4:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_SIFTFAST:BOOL=ON
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_LIBKML:BOOL=OFF
OTB_USE_LIBSVM:BOOL=OFF
OTB_USE_OPENJPEG:BOOL=OFF
OTB_USE_MAPNIK:BOOL=OFF

OTB_WRAP_PYTHON:BOOL=OFF
OTB_WRAP_JAVA:BOOL=OFF

")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)
