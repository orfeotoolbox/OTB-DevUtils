set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_DASHBOARD_ROOT "$ENV{HOME}/dashboard")
set(CTEST_BUILD_NAME "Package-Linux-gcc6-x86_64")
set(CTEST_BUILD_FLAGS "-k -j1")
set(dashboard_build_target PACKAGE-OTB)
set(CTEST_TEST_ARGS PARALLEL_LEVEL 1)
set(CTEST_SITE "arcee.c-s.fr")

set(dashboard_source_name "otb/src/SuperBuild/Packaging")
set(dashboard_binary_name "otb/pkg-otb")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/otb/src)

# special setting for ctest_submit(), issue with CA checking
set(CTEST_CURL_OPTIONS "CURLOPT_SSL_VERIFYPEER_OFF")
include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)
# cmake ~/dashboard/otb/src/SuperBuild/Packaging \
# -DSUPERBUILD_BINARY_DIR=/home/mrashad/dashboard/otb/build \
# -DDOWNLOAD_LOCATION=/media/otbnas/otb/DataForTests/SuperBuild-archives \
# -DSB_INSTALL_PREFIX=/home/mrashad/dashboard/otb/install \
# -DGENERATE_XDK=ON

set(SUPERBUILD_BINARY_DIR ${CTEST_DASHBOARD_ROOT}/otb/build)
set(SUPERBUILD_INSTALL_DIR ${CTEST_DASHBOARD_ROOT}/otb/install)

macro(dashboard_hook_init)
set(dashboard_cache "
CMAKE_INSTALL_PREFIX:PATH=/tmp/install-pkg-otb
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CMAKE_VERBOSE_MAKEFILE:BOOL=OFF
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}

BUILD_TESTING:BOOL=ON

OTB_DATA_ROOT:PATH=/media/otbnas/otb/DataForTests/OTB-Data
DOWNLOAD_LOCATION:PATH=/media/otbnas/otb/DataForTests/SuperBuild-archives
SUPERBUILD_BINARY_DIR:PATH=${SUPERBUILD_BINARY_DIR}
SUPERBUILD_INSTALL_DIR:PATH=${SUPERBUILD_INSTALL_DIR}
GENERATE_PACKAGE:BOOL=ON
OTB_WRAP_PYTHON:BOOL=ON

")
endmacro()

macro(dashboard_hook_submit)
#  dashboard_copy_packages()
endmacro() 

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
