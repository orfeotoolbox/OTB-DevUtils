# Common variables for leod dashboard
set(CTEST_DASHBOARD_ROOT "$ENV{HOME}/Dashboard")
set(CTEST_SITE "leod.c-s.fr")
set(ENV{DISPLAY} ":0.0")
set (ENV{LANG} "C")

if(NOT DEFINED CTEST_CMAKE_GENERATOR)
  set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
endif()

if(NOT DEFINED CTEST_CMAKE_COMMAND)
  set(CTEST_CMAKE_COMMAND "cmake" )
endif()

if(NOT DEFINED CTEST_TEST_ARGS)
  set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
endif()

if(NOT DEFINED CTEST_TEST_TIMEOUT)
  set(CTEST_TEST_TIMEOUT 1500)
endif()

if(NOT DEFINED CTEST_GIT_COMMAND)
  set(CTEST_GIT_COMMAND "/opt/local/bin/git")
endif()

if(NOT DEFINED CTEST_BUILD_COMMAND)
  if(NOT DEFINED dashboard_build_command)
    set(dashboard_build_command "/usr/bin/make -j8 -k" )
  endif()
endif()

