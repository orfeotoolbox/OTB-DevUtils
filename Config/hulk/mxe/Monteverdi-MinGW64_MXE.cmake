# Maintainers : OTB developers team
# Cross compilation of Monteverdi using MXE (M cross environment)
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbval/Dashboard")
set(CTEST_SITE "hulk.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Windows-64bit-Shared-${CTEST_BUILD_CONFIGURATION}-MXE_CROSS_COMPILE")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j9 -i -k install" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)

set(CTEST_HG_COMMAND "/usr/bin/hg")
set(CTEST_HG_UPDATE_OPTIONS "-C")

set(dashboard_root_name "tests")
set(dashboard_source_name "src/Monteverdi")
set(dashboard_binary_name "build/Monteverdi-MXE-64bit-${CTEST_BUILD_CONFIGURATION}")

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/Monteverdi")
set(dashboard_hg_branch "default")

##cross compile parameters
set(MXE_ROOT "/home/otbval/tools/mxe")
set(MXE_TARGET_ROOT "${MXE_ROOT}/usr/x86_64-w64-mingw32.shared")
set(CTEST_USE_LAUNCHERS OFF)

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_C_FLAGS:STRING=-Wall -Wshadow -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

BUILD_TESTING:BOOL=OFF

CMAKE_INSTALL_PREFIX:PATH=${MXE_TARGET_ROOT}
CMAKE_PREFIX_PATH:PATH=${MXE_TARGET_ROOT}

CMAKE_BUILD_TYPE:STRING=${CTEST_BUILD_CONFIGURATION}
CMAKE_TOOLCHAIN_FILE:FILEPATH=${MXE_TARGET_ROOT}/share/cmake/mxe-conf.cmake
CMAKE_USE_PTHREADS:BOOL=OFF
CMAKE_USE_WIN32_THREADS:BOOL=ON

    ")
endmacro()

set(dashboard_no_test 1)

include(${CTEST_SCRIPT_DIRECTORY}/../../otb_common.cmake)
