# Client maintainer: julien.malik@c-s.fr

SET(ENV{DISPLAY} ":0.0")
SET(ENV{TSOCKS_CONF_FILE} "/home2/otbval/.tsocks.conf")

set(dashboard_model Experimental)
set(CTEST_CMAKE_COMMAND "/ORFEO/otbval/OTB-OUTILS/cmake/2.8.2/install/bin/cmake" )
set(CTEST_DASHBOARD_ROOT "/ORFEO/otbval/OTB-NIGHTLY-VALIDATION")
set(CTEST_SITE "pc8413.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Ubuntu10.10-32bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Eclipse CDT4 - Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j6 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_GIT_COMMAND "/usr/bin/git")

set(dashboard_source_name "src/ITKv4")
set(dashboard_binary_name "build/ITKv4-${CTEST_BUILD_CONFIGURATION}")

set(dashboard_git_url "https://github.com/julienmalik/ITK.git")
set(dashboard_git_branch "WarpImageFilterForVectorImage")

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

