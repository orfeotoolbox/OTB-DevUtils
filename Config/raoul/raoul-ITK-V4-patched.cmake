# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Experimental)
set(CTEST_DASHBOARD_ROOT "C:/Users/jmalik/Dashboard")
set(CTEST_SITE "raoul.c-s.fr" )
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "OrfeoToolbox-Win7-VS2010-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR  "Visual Studio 10" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 2)
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_GIT_COMMAND "C:/Program Files (x86)/Git/bin/git.exe")

set(dashboard_source_name "src/ITKv4")
set(dashboard_binary_name "build/ITKv4-${CTEST_BUILD_CONFIGURATION}")

set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "http://itk.org/ITK.git")
set(dashboard_git_branch "release")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

    CMAKE_INCLUDE_PATH:PATH=$ENV{OSGEO4W_ROOT}/include
    CMAKE_LIBRARY_PATH:PATH=$ENV{OSGEO4W_ROOT}/lib

    BUILD_SHARED_LIBS:BOOL=OFF
    BUILD_TESTING:BOOL=OFF
    BUILD_EXAMPLES:BOOL=OFF

    # ExternalData_OBJECT_STORES:PATH=
    ITK_BUILD_ALL_MODULES:BOOL=ON

    ITK_USE_SYSTEM_HDF5:BOOL=OFF
    ITK_USE_SYSTEM_GDCM:BOOL=OFF
    ITK_USE_SYSTEM_JPEG:BOOL=OFF
    ITK_USE_SYSTEM_PNG:BOOL=OFF
    ITK_USE_SYSTEM_TIFF:BOOL=OFF
    ITK_USE_SYSTEM_ZLIB:BOOL=OFF

    # OTB depends on this
    ITK_USE_FFTWF:BOOL=ON
    ITK_USE_FFTWD:BOOL=ON
    ITK_USE_SYSTEM_FFTW:BOOL=ON
   
    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/itk_common.cmake)
