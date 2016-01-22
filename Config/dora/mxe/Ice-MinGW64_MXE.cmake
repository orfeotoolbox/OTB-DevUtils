# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)
set(CTEST_SITE "bumblebee.c-s.fr")
set(MXE_TARGET_ARCH "x86_64")
set(PROJECT "ice")
set(dashboard_git_branch "release-0.4")

#set(C_COMPILER_FLAGS)
#set(CXX_COMPILER_FLAGS)

macro(dashboard_hook_init)
set(dashboard_cache "
BUILD_TESTING:BOOL=ON
BUILD_ICE_APPLICATION:BOOL=ON
")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)
