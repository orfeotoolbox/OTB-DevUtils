set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_FLAGS "-k -j1")
include(${CTEST_SCRIPT_DIRECTORY}/scrapper_common.cmake)
include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)
set(CTEST_BUILD_NAME "Package-Linux-gcc-6-x86_64-${dashboard_git_branch}")

set(CTEST_TEST_ARGS PARALLEL_LEVEL 1)
set(dashboard_source_name "OTB/src/Packaging")
set(dashboard_binary_name "OTB/pkg-otb-stable")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/OTB/src)

set(SUPERBUILD_BINARY_DIR ${CTEST_DASHBOARD_ROOT}/OTB/superbuild_stable)
set(SUPERBUILD_INSTALL_DIR ${CTEST_DASHBOARD_ROOT}/OTB/install_sb_stable)

macro(dashboard_hook_init)
set(dashboard_cache "
CMAKE_INSTALL_PREFIX:PATH=/tmp/install-pkg-otb
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CMAKE_VERBOSE_MAKEFILE:BOOL=OFF
BUILD_TESTING:BOOL=ON
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
OTB_DATA_ROOT:PATH=${CTEST_DASHBOARD_ROOT}/OTB-Data
DOWNLOAD_LOCATION:PATH=${CTEST_DASHBOARD_ROOT}/SuperBuild-archives
SUPERBUILD_BINARY_DIR:PATH=${SUPERBUILD_BINARY_DIR}
SUPERBUILD_INSTALL_DIR:PATH=${SUPERBUILD_INSTALL_DIR}
GENERATE_PACKAGE:BOOL=ON
OTB_WRAP_PYTHON:BOOL=ON
")
endmacro()

macro(dashboard_hook_submit)
  dashboard_copy_packages()
endmacro() 

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
