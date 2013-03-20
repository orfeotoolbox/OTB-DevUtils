# Client maintainer: julien.malik@c-s.fr
SET(ENV{DISPLAY} ":0.0")
SET(ENV{CC} "/usr/bin/clang")
SET(ENV{CXX} "/usr/bin/clang++")

set(dashboard_model Experimental)
set(CTEST_DASHBOARD_ROOT "$ENV{HOME}/Dashboard/experimental")
set(CTEST_SITE "dora.c-s.fr")
set(CTEST_BUILD_CONFIGURATION RelWithDebInfo)
set(CTEST_BUILD_NAME "OrfeoToolbox-Ubuntu12.04-64bits-clang30-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Eclipse CDT4 - Unix Makefiles")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_BUILD_COMMAND "/usr/bin/make -j9 -i -k" )

set(dashboard_root_name "tests")
set(dashboard_source_name "src/ITKv4")
set(dashboard_binary_name "build/ITKv4-clang-${CTEST_BUILD_CONFIGURATION}")

set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "http://itk.org/ITK.git")
set(dashboard_git_branch "v4.3.1")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wextra
CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wextra

BUILD_SHARED_LIBS:BOOL=ON
BUILD_TESTING:BOOL=OFF
BUILD_EXAMPLES:BOOL=OFF

ExternalData_OBJECT_STORES:PATH=${CTEST_DASHBOARD_ROOT}/ITKv4-ExternalObjectStores

ITK_BUILD_ALL_MODULES:BOOL=ON
ITK_LEGACY_REMOVE:BOOL=ON

# as much external libraries as possible
# libtiff on ubuntu does not support BigTIFF and is incompatible with ITK
ITK_USE_SYSTEM_HDF5:BOOL=ON
ITK_USE_SYSTEM_GDCM:BOOL=OFF
ITK_USE_SYSTEM_JPEG:BOOL=ON
ITK_USE_SYSTEM_PNG:BOOL=ON
ITK_USE_SYSTEM_TIFF:BOOL=OFF
ITK_USE_SYSTEM_ZLIB:BOOL=ON

# OTB depends on this
ITK_USE_FFTWF:BOOL=ON
ITK_USE_FFTWD:BOOL=ON
ITK_USE_SYSTEM_FFTW:BOOL=ON

    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../itk_common.cmake)
