set(dashboard_model Nightly)
set(PROJECT otb)
set(CTEST_BUILD_CONFIGURATION Release)
set(dashboard_remote_modules 1)
set(dashboard_no_install 1)
# filter the list
set(dashboard_remote_blacklist OTBBioVars OTBPhenology OTBTemporalGapFilling)

set(MXE_TARGET_ARCH "x86_64")

include(${CTEST_SCRIPT_DIRECTORY}/bumblebee_common.cmake)

include(${CTEST_SCRIPT_DIRECTORY}/../mxe_common.cmake)
set(dashboard_cache "${mxe_common_cache}")

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
