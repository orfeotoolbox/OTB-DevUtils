set(dashboard_model Nightly)
set(OTB_PROJECT OTB)
set(CTEST_DASHBOARD_ROOT "/home/mrashad/dashboard")
set(CMAKE_COMMAND "/home/mrashad/tools/cmake-3.4.0/bin/cmake" )
set(CTEST_SITE "baker.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_CMAKE_COMMAND "${CMAKE_COMMAND}")
set(CTEST_BUILD_COMMAND "/usr/bin/make -k -j1 PACKAGE-OTB" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 1)
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_GIT_COMMAND "/usr/bin/git")
set(CTEST_USE_LAUNCHERS ON)

set(CTEST_NIGHTLY_START_TIME "20:00:00 CEST")
set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "dash.orfeo-toolbox.org")
set(CTEST_DROP_LOCATION "/submit.php?project=OTB")
set(CTEST_DROP_SITE_CDASH TRUE)

set(dashboard_source_name "otb/src/SuperBuild/Packaging")
set(dashboard_binary_name "otb/pkg-otb-stable")
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/otb/src/)

include(${CTEST_SCRIPT_DIRECTORY}/../config_stable.cmake)

set(CTEST_BUILD_NAME "Linux-x86_64-${dashboard_git_branch}-BinaryPackage")

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
  file(WRITE "${BuildLog_dir}/Configure.xml" "${configure_xml_CONTENTS_NEW}")
endmacro()

macro(dashboard_hook_end)
  execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory  ${SUPERBUILD_BINARY_DIR})
  execute_process(COMMAND ${CMAKE_COMMAND} -E make_directory    ${SUPERBUILD_BINARY_DIR})
  execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory  ${SUPERBUILD_INSTALL_DIR})
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
