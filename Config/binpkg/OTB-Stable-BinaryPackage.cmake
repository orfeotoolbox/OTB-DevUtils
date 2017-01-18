set(dashboard_model Nightly)
set(OTB_PROJECT OTB)
set(CTEST_BUILD_CONFIGURATION Release)

set(CTEST_BUILD_COMMAND "/usr/bin/make -k -j1 PACKAGE-OTB" )
include(${CTEST_SCRIPT_DIRECTORY}/binpkg_common.cmake)
set(CTEST_TEST_ARGS PARALLEL_LEVEL 1)

set(dashboard_source_name "otb/src/SuperBuild/Packaging")
set(dashboard_binary_name "otb/pkg-otb-stable")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/otb/src/)

include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)

set(CTEST_BUILD_NAME "Package-Linux-gcc-4.1.2-x86_64-${dashboard_git_branch}")

# cmake ~/dashboard/otb/src/SuperBuild/Packaging \
# -DSUPERBUILD_BINARY_DIR=/home/mrashad/dashboard/otb/build \
# -DDOWNLOAD_LOCATION=/media/otbnas/otb/DataForTests/SuperBuild-archives \
# -DSB_INSTALL_PREFIX=/home/mrashad/dashboard/otb/install \
# -DGENERATE_XDK=ON

set(SUPERBUILD_BINARY_DIR ${CTEST_DASHBOARD_ROOT}/otb/build-stable)
set(SUPERBUILD_INSTALL_DIR ${CTEST_DASHBOARD_ROOT}/otb/install-stable)

macro(dashboard_hook_init)
set(dashboard_cache "
CMAKE_INSTALL_PREFIX:PATH=/tmp/install-pkg-otb-stable
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
PYTHON_EXECUTABLE:FILEPATH=/usr/bin/python26
PYTHON_INCLUDE_DIR:PATH=/usr/include/python2.6
PYTHON_LIBRARY:FILEPATH=/usr/lib64/libpython2.6.so
NAME_SUFFIX:STRING=-gcc-4.1.2
")
endmacro()

macro(dashboard_hook_submit)
  dashboard_copy_packages()
endmacro() 

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
