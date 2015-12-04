macro(dashboard_hook_init_site)

# Testing for now
set(CTEST_DASHBOARD_TRACK Experimental)

# Machine configuration
set(CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/")

# Build configuration
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -k install" )
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")

# Test configuration
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)

endmacro()
