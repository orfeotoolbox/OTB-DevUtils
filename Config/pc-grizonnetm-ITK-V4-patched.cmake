# Client maintainer: manuel.grizonnet@cnes.fr
#SET(ENV{DISPLAY} ":0")

set(dashboard_model Experimental)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/Dashboards")
set(CTEST_SITE "pc-grizonnetm")
set(CTEST_BUILD_CONFIGURATION Debug)
set(CTEST_BUILD_NAME "OrfeoToolbox-cnes-Ubuntu10.04-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Eclipse CDT4 - Unix Makefiles")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_BUILD_COMMAND "/usr/bin/make -j6 -i -k" )

set(dashboard_root_name "My_Tests")
set(dashboard_source_name "My_Tests/ITK")
set(dashboard_binary_name "My_Tests/bin/ITKv4-${CTEST_BUILD_CONFIGURATION}")

set(dashboard_fresh_source_checkout TRUE)
set(dashboard_git_url "https://github.com/julienmalik/ITK.git")
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
    ITKV3_COMPATIBILITY:BOOL=OFF
    ITK_USE_64BITS_IDS:BOOL=OFF
    ITK_COMPUTER_MEMORY_SIZE:STRING=16
    CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wshadow -Wno-uninitialized -Wextra
    CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wshadow -Wno-uninitialized -Wextra
    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/itk_common.cmake)
