cmake_minimum_required(VERSION 2.8 FATAL_ERROR)

if(NOT DEFINED OTB_PROJECT)
  message(FATAL_ERROR "The containing script must set ${req}")
endif()

# -------------Version section -----------------------------
# update before each release
set(OTB_STABLE_VERSION 5.2)
set(MONTEVERDI_STABLE_VERSION 3.0)
# ----------------------------------------------------------

set(OTB_STABLE_DIR_SUFFIX lib/cmake/OTB-${OTB_STABLE_VERSION})
set(CTEST_BUILD_CONFIGURATION Release)

if(${OTB_PROJECT} STREQUAL "OTB")
  set(dashboard_git_branch release-${OTB_STABLE_VERSION})
elseif(${OTB_PROJECT} STREQUAL "Monteverdi2")
  set(dashboard_git_branch release-${MONTEVERDI_STABLE_VERSION})
endif()

