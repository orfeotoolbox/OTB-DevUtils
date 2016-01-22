# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)
set(CTEST_SITE "bumblebee.c-s.fr")
set(MXE_TARGET_ARCH "x86_64")
set(PROJECT "monteverdi")

#needed until we have rename repositories
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/monteverdi2.git")
set(dashboard_git_branch "release-3.0")

set(C_COMPILER_FLAGS "-Wno-uninitialized -Wno-unused-variable" CACHE STRING "")
set(CXX_COMPILER_FLAGS "-Wno-deprecated -Wno-uninitialized -Wno-unused-variable" CACHE STRING "")

macro(dashboard_hook_init)
set(dashboard_cache "
BUILD_TESTING:BOOL=ON
")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)
