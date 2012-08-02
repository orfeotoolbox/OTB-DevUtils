# Client maintainer: julien.malik@c-s.fr

SET(ENV{DISPLAY} ":0.0")
SET(ENV{TSOCKS_CONF_FILE} "/ORFEO/otbval/.tsocks.conf")

set(dashboard_model Experimental)
set(CTEST_CMAKE_COMMAND "cmake" )
set(CTEST_DASHBOARD_ROOT "$ENV{HOME}/Dashboard")
set(CTEST_SITE "dora.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "OrfeoToolbox-Ubuntu12.04-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Eclipse CDT4 - Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j6 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_GIT_COMMAND "$ENV{HOME}/bin/gittsocks.sh")

set(dashboard_source_name "experimental/ITK-V4-Release/src")
set(dashboard_binary_name "experimental/ITK-V4-Release/build")

set(dashboard_fresh_source_checkout ON)
set(dashboard_git_url "git://github.com/julienmalik/ITK.git")
set(dashboard_git_branch "OTB_ITKv4")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}
    BUILD_SHARED_LIBS:BOOL=ON
    BUILD_TESTING:BOOL=ON
    BUILD_EXAMPLES:BOOL=ON
    ITK_BUILD_ALL_MODULES:BOOL=ON
    ITK_LEGACY_SILENT:BOOL=ON
    ITK_USE_REVIEW:BOOL=ON
    ITK_USE_CONCEPT_CHECKING:BOOL=ON
    ITK_COMPUTER_MEMORY_SIZE:STRING=16
    CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wshadow -Wno-uninitialized -Wextra
    CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wshadow -Wno-uninitialized -Wextra
    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/itk_common.cmake)

