set(dashboard_module "OTBGKSVM")
set(dashboard_module_url "https://github.com/jmichel-otb/GKSVM")

set(CTEST_DASHBOARD_ROOT "$ENV{HOME}/Dashboard")
set(CTEST_SITE "leod.c-s.fr" )
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "MacOSX10.10-${CTEST_BUILD_CONFIGURATION}-${dashboard_module}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_GIT_COMMAND "/opt/local/bin/git")
set(CTEST_GIT_UPDATE_OPTIONS "reset --hard origin/nightly")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j8 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)

set(dashboard_model "Nightly")
set(dashboard_source_name "nightly/OTB-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "nightly/OTB-${CTEST_BUILD_CONFIGURATION}/build-${dashboard_module}")

set(dashboard_cache "
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data
ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/itkv4/install/lib/cmake/ITK-4.8
OSSIM_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/ossim/install/include
OSSIM_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/ossim/install/lib/libossim.dylib

BUILD_EXAMPLES:BOOL=OFF
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data
BUILD_SHARED_LIBS:BOOL=ON
BUILD_TESTING:BOOL=ON
OTB_BUILD_DEFAULT_MODULES:BOOL=OFF
Module_${dashboard_module}:BOOL=ON
")

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
