# Client maintainer: manuel.grizonnet@cnes.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/")
SET (CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Debug)
set(CTEST_BUILD_NAME "Fedora22-64bits-Minimal-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -k install" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)
set(CTEST_HG_COMMAND "/usr/bin/hg")

set(dashboard_root_name "tests")
set(dashboard_source_name "sources/orfeo/trunk/OTB-Nightly")
set(dashboard_binary_name "build/orfeo/trunk/OTB-Minimal/${CTEST_BUILD_CONFIGURATION}")

#set(dashboard_fresh_source_checkout TRUE)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-Nightly")
set(dashboard_hg_branch "default")

#set(ENV{DISPLAY} ":0.0")

set(INSTALLROOT "${CTEST_DASHBOARD_ROOT}install")
set (OTB_INSTALL_PREFIX "${INSTALLROOT}/orfeo/trunk/OTB-Minimal/${CTEST_BUILD_CONFIGURATION}")

macro(dashboard_hook_init)
set(dashboard_cache "${dashboard_cache}

#CMAKE_C_FLAGS:STRING=-Wall -Wno-uninitialized -Wno-unused-variable -Wno-unused-but-set-variable
#CMAKE_CXX_FLAGS:STRING=-Wno-cpp -Wextra
CMAKE_INSTALL_PREFIX:PATH=${OTB_INSTALL_PREFIX}

#BUILD_APPLICATIONS:BOOL=OFF
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=OFF

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/TeraDisk2/LargeInput
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}sources/orfeo/OTB-Data

## ITK
ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}build/itk/stable/Release

## OSSIM
OSSIM_INCLUDE_DIR:PATH=${INSTALLROOT}/ossim/master/include
OSSIM_LIBRARY:FILEPATH=${INSTALLROOT}/ossim/master/lib64/libossim.so

##external muparserx
#MUPARSERX_LIBRARY:PATH=${INSTALLROOT}/muparserx/stable/lib/libmuparserx.so
#MUPARSERX_INCLUDE_DIR:PATH=${INSTALLROOT}/muparserx/stable/include

#PYTHON_EXECUTABLE:FILEPATH=/usr/bin/python
OTB_WRAP_PYTHON:BOOL=OFF
OTB_WRAP_JAVA:BOOL=OFF

#OTB_USE_XXX
OTB_USE_6S=OFF
OTB_USE_CURL=OFF
OTB_USE_LIBKML=OFF
OTB_USE_LIBSVM=OFF
OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_MUPARSER:BOOL=OFF
OTB_USE_MUPARSERX:BOOL=OFF
OTB_USE_OPENCV:BOOL=OFF
OTB_USE_OPENJPEG=OFF
OTB_USE_QT4=OFF
OTB_USE_SIFTFAST=OFF
 ")

endmacro()
include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
