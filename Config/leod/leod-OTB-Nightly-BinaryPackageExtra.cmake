set(CTEST_BUILD_CONFIGURATION Release)
set(dashboard_model Nightly)
set(CTEST_BUILD_FLAGS -j1)
include(${CTEST_SCRIPT_DIRECTORY}/leod_common.cmake)
include(${CTEST_SCRIPT_DIRECTORY}/../macro_common.cmake)
string(TOLOWER ${dashboard_model} lcdashboard_model)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/src)

#-------------------------------------------------------------------------------
# First, compile & install the external modules in current SuperBuild
set(CTEST_BINARY_DIRECTORY "${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-SuperBuild/build/OTB/build")
set(CTEST_SOURCE_DIRECTORY "${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-Release/src")
set(CTEST_BUILD_NAME "MacOSX-10.10-SuperBuild-contrib")
set(CTEST_BUILD_FLAGS -j8)

#disable warnings on superbuild contrib
set(CTEST_CUSTOM_MAXIMUM_NUMBER_OF_WARNINGS 0)

ctest_start(Nightly TRACK SuperBuild)
set_git_update_command(nightly)
ctest_update()
ctest_build(TARGET uninstall)
# 3 official remote modules are not packages because of missing GSL dependency
# enable_official_remote_modules(${CTEST_SOURCE_DIRECTORY} cache_remote_modules)
ctest_configure(OPTIONS "-DModule_Mosaic:BOOL=ON;-DModule_otbGRM:BOOL=ON;-DModule_SertitObject:BOOL=ON;-DModule_OTBFFSforGMM:BOOL=ON")
ctest_build(TARGET install)
ctest_test(BUILD "${CTEST_DASHBOARD_ROOT}/build/OTB-SuperBuild/build")
ctest_submit()

unset(CTEST_BINARY_DIRECTORY)
unset(CTEST_SOURCE_DIRECTORY)
unset(CTEST_CUSTOM_MAXIMUM_NUMBER_OF_WARNINGS)
set(CTEST_BUILD_FLAGS -j1)
#-------------------------------------------------------------------------------

set(CTEST_BUILD_NAME "Package-MacOSX-10.10-contrib")

set(dashboard_source_name "${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/src/Packaging")
set(dashboard_binary_name "${lcdashboard_model}/OTB-SuperBuild/pkg-otb-contrib")

set(OTB_SB_INSTALL_DIR ${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-SuperBuild/install)
set(OTB_SB_BINARY_DIR  ${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-SuperBuild/build)

macro(dashboard_hook_init)
set(dashboard_cache "
CMAKE_INSTALL_PREFIX:PATH=/tmp/install-pkg-otb
CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CMAKE_VERBOSE_MAKEFILE:BOOL=OFF
CTEST_USE_LAUNCHERS:BOOL=${CTEST_USE_LAUNCHERS}

BUILD_TESTING:BOOL=ON
OTB_DATA_ROOT:PATH=$ENV{HOME}/Data/OTB-Data
DOWNLOAD_LOCATION:PATH=$ENV{HOME}/Data/SuperBuild-archives
SUPERBUILD_BINARY_DIR:PATH=${OTB_SB_BINARY_DIR}
SUPERBUILD_INSTALL_DIR:PATH=${OTB_SB_INSTALL_DIR}
GENERATE_PACKAGE:BOOL=ON
NAME_SUFFIX:STRING=-contrib
")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)

