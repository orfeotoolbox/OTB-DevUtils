cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

# ------------- Version section (update before each release)------------------ 
set(OTB_STABLE_VERSION 6.0)
# ----------------------------------------------------------

set(OTB_STABLE_DIR_SUFFIX lib/cmake/OTB-${OTB_STABLE_VERSION})
set(CTEST_BUILD_CONFIGURATION Release)

set(dashboard_git_branch release-${OTB_STABLE_VERSION})
set(specific_data_branch_for_${dashboard_git_branch} release-${OTB_STABLE_VERSION})
