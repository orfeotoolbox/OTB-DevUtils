set(CTEST_DASHBOARD_ROOT "/home/mrashad/dashboard")
set(CTEST_SITE "binpkg.c-s.fr")

if(NOT DEFINED CTEST_CMAKE_GENERATOR)
  set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
endif()

if(NOT DEFINED CTEST_GIT_COMMAND)
  set(CTEST_GIT_COMMAND "/usr/bin/git")
endif()

if(NOT DEFINED CTEST_TEST_ARGS)
  set(CTEST_TEST_ARGS PARALLEL_LEVEL 3)
endif()

if(NOT DEFINED CTEST_TEST_TIMEOUT)
  set(CTEST_TEST_TIMEOUT 1500)
endif()

if(NOT DEFINED CTEST_USE_LAUNCHERS)
  set(CTEST_USE_LAUNCHERS ON)
endif()

if(NOT DEFINED CTEST_BUILD_FLAGS)
  set(CTEST_BUILD_FLAGS "-k")
endif()

set(CMAKE_MAKE_PROGRAM "/usr/bin/make")

# special setting for ctest_submit(), issue with CA checking
set(CTEST_CURL_OPTIONS "CURLOPT_SSL_VERIFYPEER_OFF")
