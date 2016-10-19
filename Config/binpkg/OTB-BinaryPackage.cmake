set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/mrashad/dashboard")
set(CTEST_SITE "binpkg.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Package-Linux-x86_64")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -k -j1 PACKAGE-OTB" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 1)
set(CTEST_TEST_TIMEOUT 500)

set(dashboard_source_name "otb/src/SuperBuild/Packaging")
set(dashboard_binary_name "otb/pkg-otb")
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/otb/src/)

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
PYTHON_EXECUTABLE:FILEPATH=/usr/bin/python26
PYTHON_INCLUDE_DIR:PATH=/usr/include/python2.6
PYTHON_LIBRARY:FILEPATH=/usr/lib64/libpython2.6.so

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
  # file(WRITE "${BuildLog_dir}/Configure.xml" "${configure_xml_CONTENTS_NEW}")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
