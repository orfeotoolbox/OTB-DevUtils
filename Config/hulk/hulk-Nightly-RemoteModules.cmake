# Run nightly test on each remote module
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Ubuntu14.04-64bits-${CTEST_BUILD_CONFIGURATION}")
include(${CTEST_SCRIPT_DIRECTORY}/hulk_common.cmake)
set(dashboard_remote_modules 1)
set(dashboard_no_install 1)

set(dashboard_model "Nightly")
set(dashboard_source_name "src/OTB")
set(dashboard_binary_name "build/build-remotes")

# filter the list
set(dashboard_remote_blacklist OTBBioVars OTBPhenology OTBTemporalGapFilling)

set(dashboard_cache "
BUILD_EXAMPLES:BOOL=OFF
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data
ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/ITK-4.10.0/lib/cmake/ITK-4.10
BUILD_SHARED_LIBS:BOOL=ON
BUILD_TESTING:BOOL=ON
OTB_BUILD_DEFAULT_MODULES:BOOL=OFF
Module_${dashboard_module}:BOOL=ON
")

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
