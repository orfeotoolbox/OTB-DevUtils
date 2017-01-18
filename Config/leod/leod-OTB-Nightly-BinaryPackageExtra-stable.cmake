set(CTEST_BUILD_CONFIGURATION Release)
set(OTB_PROJECT OTB)

set(dashboard_model Nightly)
set(dashboard_no_install 1)
set(dashboard_build_command "/usr/bin/make -j1  PACKAGE-OTB" )
include(${CTEST_SCRIPT_DIRECTORY}/leod_common.cmake)
include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)
include(${CTEST_SCRIPT_DIRECTORY}/../macro_common.cmake)
string(TOLOWER ${dashboard_model} lcdashboard_model)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/src)

#-------------------------------------------------------------------------------
# First, compile & install the external modules in current SuperBuild
set(CTEST_BINARY_DIRECTORY "/Users/otbval/Dashboard/nightly/OTB-SuperBuild/build-stable/OTB/build")
set(CTEST_SOURCE_DIRECTORY "/Users/otbval/Dashboard/nightly/OTB-Release/src")
set(CTEST_BUILD_NAME "MacOSX-10.10-SuperBuild-contrib-${dashboard_git_branch}")
set(CTEST_BUILD_FLAGS -j8)
set(CTEST_GIT_UPDATE_CUSTOM  ${CMAKE_COMMAND} -D GIT_COMMAND:PATH=git -D TESTED_BRANCH:STRING=${dashboard_git_branch} -P ${CTEST_SCRIPT_DIRECTORY}/../git_updater.cmake)

ctest_start(Nightly TRACK SuperBuild)
ctest_update()
ctest_build(TARGET uninstall)
get_cache_for_remote_modules(${CTEST_SOURCE_DIRECTORY} cache_remote_modules)
ctest_configure(OPTIONS "${cache_remote_modules}")
ctest_build(TARGET install)
ctest_submit()

unset(CTEST_BINARY_DIRECTORY)
unset(CTEST_SOURCE_DIRECTORY)
unset(CTEST_GIT_UPDATE_CUSTOM)
unset(CTEST_BUILD_FLAGS)
#-------------------------------------------------------------------------------

set(CTEST_BUILD_NAME "Package-MacOSX-10.10-contrib-${dashboard_git_branch}")

set(dashboard_source_name "${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/src/SuperBuild/Packaging")
set(dashboard_binary_name "${lcdashboard_model}/OTB-SuperBuild/pkg-otb-contrib-stable")

set(OTB_SB_INSTALL_DIR ${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-SuperBuild/install-stable)
set(OTB_SB_BINARY_DIR  ${CTEST_DASHBOARD_ROOT}/${lcdashboard_model}/OTB-SuperBuild/build-stable)

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

macro(dashboard_hook_test)
  # This is hecky way to get the build log of packaging
  # in the configure part on dashboard. I am not proud of
  # what happens below. But you gotta do what you gotta do right?
  set(Testing_DIR ${CTEST_DASHBOARD_ROOT}/${dashboard_binary_name}/Testing)
  #what happens if year is 2100?. Then we update below line!
  file(GLOB CTestLaunchConfig_file "${Testing_DIR}/20*/Build/*.cmake")
  get_filename_component(BuildLog_dir ${CTestLaunchConfig_file} PATH)
  get_filename_component(BuildLog_dir ${BuildLog_dir} PATH)
  file(STRINGS "${BuildLog_dir}/Configure.xml" configure_xml_CONTENTS)
  file(GLOB LastBuildLog "${Testing_DIR}/Temporary/LastBuild_*.log")
  file(STRINGS "${LastBuildLog}" LastBuildLog_CONTENTS)
  string(REPLACE "</Log>" "${LastBuildLog_CONTENTS}\n</Log>" configure_xml_CONTENTS_NEW "${configure_xml_CONTENTS}")
  string(REPLACE ";" "\n" configure_xml_CONTENTS_NEW "${configure_xml_CONTENTS_NEW}")
  # file(WRITE "${BuildLog_dir}/Configure.xml" ${configure_xml_CONTENTS_NEW})
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)

