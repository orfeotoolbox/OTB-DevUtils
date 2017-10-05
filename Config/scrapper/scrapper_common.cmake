# Common variables for scrapper dashboard (CentOS6 VM)
set(CTEST_DASHBOARD_ROOT "/home/otbval/Dashboard")
set(CTEST_SITE "scrapper.c-s.fr")

if(NOT DEFINED CTEST_CMAKE_GENERATOR)
  set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
endif()

if(NOT DEFINED CTEST_GIT_COMMAND)
  set(CTEST_GIT_COMMAND "/usr/bin/git")
endif()

if(NOT DEFINED CTEST_TEST_ARGS)
  set(CTEST_TEST_ARGS PARALLEL_LEVEL 2)
endif()

if(NOT DEFINED CTEST_TEST_TIMEOUT)
  set(CTEST_TEST_TIMEOUT 1500)
endif()

if(NOT DEFINED CTEST_USE_LAUNCHERS)
  set(CTEST_USE_LAUNCHERS ON)
endif()

if(NOT DEFINED CTEST_BUILD_FLAGS)
  set(CTEST_BUILD_FLAGS "-j2 -k")
endif()

set(CMAKE_MAKE_PROGRAM "make")

