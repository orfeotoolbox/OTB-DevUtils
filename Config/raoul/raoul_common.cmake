# Client maintainer: julien.malik@c-s.fr
foreach(req
    OTB_PROJECT
    OTB_ARCH
    )
  if(NOT DEFINED ${req})
    message(FATAL_ERROR "The containing script must set ${req}")
  endif()
endforeach()

if (NOT DEFINED dashboard_model)
  set(dashboard_model Nightly)
endif()

if (NOT DEFINED CTEST_DASHBOARD_ROOT)
set(CTEST_DASHBOARD_ROOT "C:/Users/jmalik/Dashboard")
endif()

file(TO_CMAKE_PATH $ENV{OSGEO4W_ROOT} OSGEO4W_ROOT)
message("OSGEO4W_ROOT is ${OSGEO4W_ROOT}")

if (NOT DEFINED CTEST_SITE)
set(CTEST_SITE "raoul.c-s.fr" )
endif()

if (NOT DEFINED CTEST_CMAKE_GENERATOR)
if (${OTB_ARCH} STREQUAL "x86")
  set(CTEST_CMAKE_GENERATOR  "Visual Studio 10" )
elseif(${OTB_ARCH} STREQUAL "amd64")
  set(CTEST_CMAKE_GENERATOR  "Visual Studio 10 Win64" )
endif()
endif()

if (NOT DEFINED CTEST_TEST_ARGS)
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
endif()

if (NOT DEFINED CTEST_TEST_TIMEOUT)
set(CTEST_TEST_TIMEOUT 1500)
endif()

set(CTEST_GIT_COMMAND "C:/Program Files (x86)/Git/bin/git.exe")
set(CTEST_CMAKE_COMMAND "C:/Program Files (x86)/CMake 2.8/bin/cmake.exe")
set(CTEST_HG_COMMAND "C:/Program Files (x86)/Mercurial/hg.exe")

# build a shorted binary path (OTB needs source and binary paths < 50)
if (${OTB_ARCH} STREQUAL "x86")
  set(OTB_ARCH_SHORT  "32b" )
elseif(${OTB_ARCH} STREQUAL "amd64")
  set(OTB_ARCH_SHORT  "64b" )
endif()

if(${CTEST_BUILD_CONFIGURATION} STREQUAL "Release")
  set(BUILD_CONF_SHORT "Rel")
elseif(${CTEST_BUILD_CONFIGURATION} STREQUAL "Debug")
  set(BUILD_CONF_SHORT "Dbg")
elseif(${CTEST_BUILD_CONFIGURATION} STREQUAL "RelWithDebInfo")
  set(BUILD_CONF_SHORT "RDI")
endif()


if (NOT DEFINED CTEST_BUILD_NAME)
set(CTEST_BUILD_NAME "Win7-vc10-${OTB_ARCH}-${CTEST_BUILD_CONFIGURATION}-Static")
endif()
if (NOT DEFINED dashboard_source_name)
set(dashboard_source_name "src/${OTB_PROJECT}")
endif()
if (NOT DEFINED dashboard_binary_name)
set(dashboard_binary_name "build/${OTB_PROJECT}-vc10-${OTB_ARCH_SHORT}-${BUILD_CONF_SHORT}")
endif()

if (NOT DEFINED dashboard_fresh_source_checkout)
set(dashboard_fresh_source_checkout OFF)
endif()
if (NOT DEFINED dashboard_hg_url)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/${OTB_PROJECT}")
endif()
if (NOT DEFINED dashboard_hg_branch)
set(dashboard_hg_branch "default")
endif()
