set(dashboard_module "Mosaic")
# set(dashboard_module_url "https://github.com/jmichel-otb/GKSVM")

set(CTEST_DASHBOARD_ROOT "/home/otbval/Dashboard")
set(CTEST_SITE "dora.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "${dashboard_module}-Ubuntu12.04-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_GIT_COMMAND "/usr/bin/git")
set(CTEST_GIT_UPDATE_OPTIONS "reset --hard origin/nightly")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j8 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)

set(dashboard_model "Nightly")
set(dashboard_source_name "nightly/OTB-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "nightly/OTB-${CTEST_BUILD_CONFIGURATION}/build-${dashboard_module}")

set(dashboard_cache "
BUILD_EXAMPLES:BOOL=OFF
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data
BUILD_SHARED_LIBS:BOOL=ON
BUILD_TESTING:BOOL=ON
OTB_BUILD_DEFAULT_MODULES:BOOL=OFF
CMAKE_C_FLAGS:STRING= -fPIC -Wall -Wno-shadow
CMAKE_CXX_FLAGS:STRING= -fPIC -Wall -Wno-shadow -Wno-unused-parameter -Wno-unused-result -Wno-unused-but-set-parameter
Module_${dashboard_module}:BOOL=ON
")

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
