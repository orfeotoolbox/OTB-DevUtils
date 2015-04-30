# Client maintainer: manuel.grizonnet@cnes.fr
#This is MinGW MXE cross compilation script.
set(CTEST_DASHBOARD_ROOT "/home/otbtesting")
set(CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(MXE_ROOT "${CTEST_DASHBOARD_ROOT}/win-sources/mxe")
set(MXE_TARGET_ARCH "i686")
set(PROJECT "OTB")
set(dashboard_source_name "sources/orfeo/trunk/OTB-Nightly")
set(dashboard_binary_name "build/orfeo/trunk/OTB-MinGW-i686-MXE/${CTEST_BUILD_CONFIGURATION}")
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-Nightly")

# append mxe build script and log as notes for remote debugging
list(APPEND CTEST_NOTES_FILES
  "${CTEST_DASHBOARD_ROOT}/logs/mxe_i686-w64-mingw32.shared_build.log"
  "${CTEST_DASHBOARD_ROOT}/sources/orfeo/OTB-DevUtils/Scripts/mxe_build.sh")

set(dashboard_no_test 1)

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
OTB_USE_QT4:BOOL=ON

OTB_USE_OPENCV:BOOL=ON
OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_SIFTFAST:BOOL=OFF
OTB_USE_OPENJPEG:BOOL=OFF
OTB_USE_LIBKML:BOOL=OFF
OTB_USE_LIBSVM:BOOL=OFF

")

endmacro()
