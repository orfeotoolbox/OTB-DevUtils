# Maintainers : OTB developers team
# Cross compilation of OTB library using MXE (M cross environment)
set(CTEST_SITE "bumblebee.c-s.fr")
set(MXE_TARGET_ARCH "i686")
set(PROJECT "monteverdi")

#needed until we have rename repositories
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/monteverdi2.git")

set(dashboard_cc_flags "-Wno-uninitialized -Wno-unused-variable")
set(dashboard_cxx_flags "-Wno-deprecated -Wno-uninitialized -Wno-unused-variable")

set(dashboard_git_branch release-3.4)

macro(dashboard_hook_init)
set(dashboard_cache "

${mxe_common_cache}

OTB_SOURCE_DIR:PATH=/data/dashboard/nightly/otb-Release/src
GENERATE_PACKAGE=ON
")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../../mxe_common.cmake)

include(${CTEST_SCRIPT_DIRECTORY}/../../otb_common.cmake)
