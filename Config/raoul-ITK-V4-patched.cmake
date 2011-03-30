# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Experimental)
set(CTEST_DASHBOARD_ROOT "C:/Users/jmalik/Dashboard")
set(CTEST_SITE "raoul.c-s.fr" )
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "OTB-Win7-VC2008-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR  "Visual Studio 9 2008" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 2)
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_GIT_COMMAND "C:/Program Files (x86)/Git/bin/git.exe")

set(dashboard_source_name "src/ITKv4")
set(dashboard_binary_name "build/ITKv4-${CTEST_BUILD_CONFIGURATION}")

set(dashboard_git_url "https://github.com/julienmalik/ITK.git")
set(dashboard_git_branch "WarpImageFilterForVectorImage")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}
    BUILD_TESTING:BOOL=ON
    BUILD_EXAMPLES:BOOL=ON
    ITK_BUILD_ALL_MODULES:BOOL=ON
    Module_ITK-Review:BOOL=ON
    ITK_USE_REVIEW:BOOL=ON
    BUILD_SHARED_LIBS:BOOL=OFF
    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/itk_common.cmake)
