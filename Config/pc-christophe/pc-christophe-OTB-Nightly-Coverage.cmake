# Client maintainer: manuel.grizonnet@cnes.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/")
set(CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Debug)
set(CTEST_BUILD_NAME "Fedora20-64bits-Coverage-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k" )
set(CTEST_COVERAGE_COMMAND "/usr/bin/gcov")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)
set(CTEST_HG_COMMAND "/usr/bin/hg")

set(dashboard_root_name "tests")
set(dashboard_source_name "sources/orfeo/trunk/OTB-Nightly")
set(dashboard_binary_name "build/orfeo/trunk/OTB-Nightly-Coverage/${CTEST_BUILD_CONFIGURATION}")

#set(dashboard_fresh_source_checkout TRUE)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-Nightly")
set(dashboard_hg_branch "default")

set(dashboard_do_coverage true)
set(INSTALLROOT "${CTEST_DASHBOARD_ROOT}install")

macro(dashboard_hook_init)
set(dashboard_cache "${dashboard_cache}
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
BUILD_APPLICATIONS:BOOL=ON

CMAKE_C_FLAGS:STRING=-g -O0 -fprofile-arcs -ftest-coverage  -Wall -Wno-uninitialized  -Wno-unused-variable -Wno-unused-but-set-variable
CMAKE_CXX_FLAGS:STRING=-g -O0 -fprofile-arcs -ftest-coverage -Wall -Wno-deprecated -Wno-uninitialized -Wno-cpp

## ITK
ITK_DIR:PATH=${INSTALLROOT}/itk/stable/Release/lib/cmake/ITK-4.7

## OSSIM
OSSIM_INCLUDE_DIR:PATH=${INSTALLROOT}/ossim/stable/include
OSSIM_LIBRARY:FILEPATH=${INSTALLROOT}/ossim/stable/lib64/libossim.so

##external muparserx
MUPARSERX_LIBRARY:PATH=${INSTALLROOT}/muparserx/lib/libmuparserx.so
MUPARSERX_INCLUDE_DIR:PATH=${INSTALLROOT}/muparserx/include

#external openjpeg
OpenJPEG_DIR:PATH=${INSTALLROOT}/openjpeg/stable/lib/openjpeg-2.0

OTB_DATA_LARGEINPUT_ROOT:STRING=/media/TeraDisk2/LargeInput
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}sources/orfeo/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=ON

# These options are not available anymore
OTB_USE_PATENTED:BOOL=ON
OTB_USE_CURL:BOOL=ON

PYTHON_EXECUTABLE:FILEPATH=/usr/bin/python
OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON

OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_OPENCV:BOOL=ON
OTB_USE_QT4=ON
OTB_USE_LIBKML=ON
OTB_USE_6S=ON
OTB_USE_SIFTFAST=ON
")

endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
