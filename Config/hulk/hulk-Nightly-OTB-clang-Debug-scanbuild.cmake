# Client maintainer: julien.malik@c-s.fr
set(SCANBUILD_DIR "$ENV{HOME}/tools/src/llvm/tools/clang/tools/scan-build")

set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbval/Dashboard")
set(CTEST_SITE "hulk.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Debug)
set(CTEST_BUILD_NAME "Ubuntu14.04-64bits-clang-${CTEST_BUILD_CONFIGURATION}-scanbuild")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "${SCANBUILD_DIR}/scan-build /usr/bin/make -j9 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)
set(CTEST_HG_COMMAND "/usr/bin/hg")

set(dashboard_root_name "tests")
set(dashboard_source_name "src/OTB")
set(dashboard_binary_name "build/OTB-clang-${CTEST_BUILD_CONFIGURATION}-scanbuild")

set(dashboard_no_submit ON)
#set(dashboard_fresh_source_checkout TRUE)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-Nightly")
set(dashboard_hg_branch "default")

set(ENV{CCC_CC}   "$ENV{HOME}/tools/install/llvm/bin/clang")
set(ENV{CCC_CXX}  "$ENV{HOME}/tools/install/llvm/bin/clang++")
set(ENV{PATH}     "$ENV{HOME}/tools/install/llvm/bin:$ENV{PATH}")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON

CMAKE_C_COMPILER=${SCANBUILD_DIR}/ccc-analyzer
CMAKE_CXX_COMPILER=${SCANBUILD_DIR}/ccc-analyzer

CMAKE_C_FLAGS:STRING= -fPIC -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -fPIC -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable -Wno-gnu -Wno-overloaded-virtual

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/home/otbval/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Dashboard/src/OTB-Data

ITK_USE_PATENTED:BOOL=ON
ITK_USE_REVIEW:BOOL=ON 
ITK_USE_OPTIMIZED_REGISTRATION_METHODS:BOOL=ON 
USE_FFTWD:BOOL=ON
USE_FFTWF:BOOL=ON
OTB_GL_USE_ACCEL:BOOL=OFF
OTB_USE_MAPNIK:BOOL=OFF

BOOST_ROOT:PATH=$ENV{HOME}/tools/install/boost-1.49.0

    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)

