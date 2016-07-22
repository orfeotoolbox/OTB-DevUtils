set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting")
set(CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Fedora22-64bits-CookBook")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 1)
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_USE_LAUNCHERS OFF)
set(CTEST_GIT_COMMAND "/usr/bin/git")

set(CTEST_DASHBOARD_TRACK Develop)

set(dashboard_root_name "tests")
set(dashboard_source_name "sources/orfeo/otb-documents/CookBook")
set(dashboard_binary_name "build/orfeo/otb-documents/Cookbook")

set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb-documents.git")
set(dashboard_update_dir ${CTEST_DASHBOARD_ROOT}/sources/orfeo/otb-documents)
set(dashboard_git_branch master)

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}

OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/sources/orfeo/OTB-Data
OTB_DATA_PATHS:STRING=${CTEST_DASHBOARD_ROOT}/sources/orfeo/OTB-Data/Examples::${CTEST_DASHBOARD_ROOT}/sources/orfeo/OTB-Data/Input

OTB_DIR:STRING=${CTEST_DASHBOARD_ROOT}/build/orfeo/trunk/OTB-Nightly/Release
")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
