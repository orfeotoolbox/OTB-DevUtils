set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Package-MacOSX-10.10")

set(dashboard_model Nightly)
#set(dashboard_no_install 1)
set(CTEST_BUILD_FLAGS -j1)
set(dashboard_build_target PACKAGE-OTB)
include(${CTEST_SCRIPT_DIRECTORY}/leod_common.cmake)
string(TOLOWER ${dashboard_model} lcdashboard_model)
set(dashboard_source_name "nightly/OTB-${CTEST_BUILD_CONFIGURATION}/src/Packaging")
set(dashboard_binary_name "nightly/OTB-SuperBuild/pkg-otb")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/nightly/OTB-${CTEST_BUILD_CONFIGURATION}/src)

set(OTB_SB_INSTALL_DIR ${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-SuperBuild/install)
set(OTB_SB_BINARY_DIR  ${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-SuperBuild/build)

macro(dashboard_hook_init)
set(dashboard_cache "
CMAKE_INSTALL_PREFIX:PATH=/tmp/install-pkg-otb
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}
BUILD_TESTING:BOOL=ON
DOWNLOAD_LOCATION:PATH=$ENV{HOME}/Data/SuperBuild-archives
SUPERBUILD_BINARY_DIR:PATH=${OTB_SB_BINARY_DIR}
SUPERBUILD_INSTALL_DIR:PATH=${OTB_SB_INSTALL_DIR}
OMP_LIB_DIR:PATH=/Users/otbval/local/llvm/7.0/lib/
")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
