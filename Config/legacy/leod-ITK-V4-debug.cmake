# Client maintainer: julien.malik@c-s.fr
SET(ENV{DISPLAY} ":0.0")

set(dashboard_model Experimental)
set(CTEST_DASHBOARD_ROOT "/Users/otbval/Dashboard")
set(CTEST_SITE "leod.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Debug)
set(CTEST_BUILD_NAME "OrfeoToolbox-MacOSX10.8-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_BUILD_COMMAND "/usr/bin/make -j5 -i -k" )

set(dashboard_root_name "tests")
set(dashboard_source_name "itkv4/src")
set(dashboard_binary_name "itkv4/build")

set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "http://itk.org/ITK.git")
set(dashboard_git_branch "v4.5.0")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wextra
CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wextra

BUILD_SHARED_LIBS:BOOL=ON
BUILD_TESTING:BOOL=OFF
BUILD_EXAMPLES:BOOL=OFF

CMAKE_LIBRARY_PATH:PATH=/opt/local/lib
CMAKE_INCLUDE_PATH:PATH=/opt/local/include

ITK_BUILD_DEFAULT_MODULES:BOOL=ON

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

ITK_LEGACY_REMOVE:BOOL=ON

    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/itk_common.cmake)
