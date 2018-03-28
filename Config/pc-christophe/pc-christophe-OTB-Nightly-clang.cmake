# Client maintainer: manuel.grizonnet@cnes.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/")
SET (CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Fedora27-64bits-clang-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_FLAGS "-j4 -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)
set(dashboard_root_name "tests")
set(dashboard_source_name "sources/orfeo/trunk/OTB-Nightly")
set(dashboard_binary_name "build/orfeo/trunk/OTB-Nightly-clang/${CTEST_BUILD_CONFIGURATION}")

#set(ENV{DISPLAY} ":0.0")

set(INSTALLROOT "${CTEST_DASHBOARD_ROOT}/install")
set (CTEST_INSTALL_DIRECTORY "${INSTALLROOT}/orfeo/trunk/OTB-Nightly-clang/${CTEST_BUILD_CONFIGURATION}")
#execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory "${CTEST_INSTALL_DIRECTORY}")

macro(dashboard_hook_init)
set(dashboard_cache "${dashboard_cache}

CMAKE_C_COMPILER=/usr/bin/clang
CMAKE_CXX_COMPILER=/usr/bin/clang++
CMAKE_C_FLAGS:STRING=-Wall
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-gnu-static-float-init -Wno-\\\\#warnings -Wno-unknown-attributes -Wno-shadow
CMAKE_INSTALL_PREFIX=${CTEST_INSTALL_DIRECTORY}

BUILD_APPLICATIONS:BOOL=ON
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/TeraDisk2/LargeInput
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}sources/orfeo/OTB-Data

## ITK
ITK_DIR:PATH=${INSTALLROOT}/itk/stable/Release/lib/cmake/ITK-4.13

## OSSIM
OSSIM_INCLUDE_DIR:PATH=${INSTALLROOT}/ossim/release/include
OSSIM_LIBRARY:FILEPATH=${INSTALLROOT}/ossim/release/lib64/libossim.so

##external muparserx
MUPARSERX_LIBRARY:PATH=${INSTALLROOT}/muparserx/stable/lib/libmuparserx.so
MUPARSERX_INCLUDE_DIR:PATH=${INSTALLROOT}/muparserx/stable/include/muparserx


PYTHON_EXECUTABLE:FILEPATH=/usr/bin/python
OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON

#OTB_USE_XXX
OTB_USE_6S=ON
OTB_USE_CURL=ON
OTB_USE_LIBKML=OFF
OTB_USE_LIBSVM=ON
OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_QT4=ON
OTB_USE_SIFTFAST=ON
# MPI and SPTW
OTB_USE_MPI:BOOL=ON
OTB_USE_SPTW:BOOL=ON
 ")

endmacro()
include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
