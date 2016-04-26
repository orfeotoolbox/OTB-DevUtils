# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)
set(CTEST_SITE "bumblebee.c-s.fr")
set(MXE_TARGET_ARCH "x86_64")
set(PROJECT "monteverdi")

#needed until we have rename repositories
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/monteverdi2.git")

set(dashboard_cc_flags "-Wno-uninitialized -Wno-unused-variable")
set(dashboard_cxx_flags "-Wno-deprecated -Wno-uninitialized -Wno-unused-variable")

macro(dashboard_hook_init)
set(dashboard_cache "
OTB_SOURCE_DIR:PATH=/data/dashboard/nightly/otb-Release/src
")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)
