cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

if(NOT DEFINED OTB_PROJECT)
  message(FATAL_ERROR "The containing script must set OTB_PROJECT")
endif()

# --------- Common switch to enable/disable release builds --------------------
set(CONFIG_STABLE_SWITCH ON)
# ------------- Version section -----------------------------
# update before each release
set(OTB_STABLE_VERSION 5.8)
set(MONTEVERDI_STABLE_VERSION 3.4)
# ----------------------------------------------------------

set(OTB_STABLE_DIR_SUFFIX lib/cmake/OTB-${OTB_STABLE_VERSION})
set(CTEST_BUILD_CONFIGURATION Release)

if(${OTB_PROJECT} STREQUAL "OTB")
  set(dashboard_git_branch release-${OTB_STABLE_VERSION})
  set(specific_data_branch_for_${dashboard_git_branch} release-${OTB_STABLE_VERSION})
elseif(${OTB_PROJECT} STREQUAL "Monteverdi2")
  set(dashboard_git_branch release-${MONTEVERDI_STABLE_VERSION})
endif()

if(NOT CONFIG_STABLE_SWITCH)
  message(FATAL_ERROR "Stable builds not enabled, silent exit")
endif()
