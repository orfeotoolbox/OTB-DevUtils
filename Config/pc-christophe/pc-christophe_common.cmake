# Common variables for hulk dashboard
set(CTEST_DASHBOARD_ROOT "/home/otbtesting")
set(CTEST_SITE "pc-christophe.cst.cnes.fr")

if(NOT DEFINED CTEST_CMAKE_GENERATOR)
  set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
endif()

if(NOT DEFINED CTEST_GIT_COMMAND)
  set(CTEST_GIT_COMMAND "/usr/bin/git")
endif()

if(NOT DEFINED CTEST_TEST_ARGS)
  set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
endif()

if(NOT DEFINED CTEST_TEST_TIMEOUT)
  set(CTEST_TEST_TIMEOUT 1500)
endif()

if(NOT DEFINED CTEST_USE_LAUNCHERS)
  set(CTEST_USE_LAUNCHERS ON)
endif()

if(NOT DEFINED CTEST_BUILD_COMMAND)
  if(NOT DEFINED dashboard_build_command)
    set(dashboard_build_command "/usr/bin/make -j4 -k")
  endif()
endif()

