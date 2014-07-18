# Client maintainer: manuel.grizonnet@cnes.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/")
SET (CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Fedora20-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k install" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)
set(CTEST_HG_COMMAND "/usr/bin/hg")

set(dashboard_root_name "tests")
set(dashboard_source_name "sources/orfeo/trunk/OTB-Nightly")
set(dashboard_binary_name "build/orfeo/trunk/OTB-Nightly/${CTEST_BUILD_CONFIGURATION}")

#set(dashboard_fresh_source_checkout TRUE)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-Nightly")
set(dashboard_hg_branch "default")

#set(ENV{DISPLAY} ":0.0")

set(INSTALLROOT "${CTEST_DASHBOARD_ROOT}install")
set (OTB_INSTALL_PREFIX "${INSTALLROOT}/orfeo/trunk/OTB-Nightly/${CTEST_BUILD_CONFIGURATION}")

macro(dashboard_hook_init)
set(dashboard_cache "${dashboard_cache}

CMAKE_C_FLAGS:STRING=-Wall -Wno-uninitialized -Wno-unused-variable -Wno-unused-but-set-variable
CMAKE_CXX_FLAGS:STRING=-Wno-cpp -Wextra
CMAKE_INSTALL_PREFIX:PATH=${OTB_INSTALL_PREFIX}

BUILD_APPLICATIONS:BOOL=ON
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON

OTB_COMPILE_WITH_FULL_WARNING=ON
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/ssh/pc-inglada/media/TeraDisk2/LargeInput
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}sources/orfeo/OTB-Data

##external ITK
OTB_USE_EXTERNAL_ITK:BOOL=ON
ITK_DIR:PATH=${INSTALLROOT}/itk/stable/Release/lib/cmake/ITK-4.6

##external OSSIM
OTB_USE_EXTERNAL_OSSIM:BOOL=ON
OSSIM_INCLUDE_DIR:PATH=${INSTALLROOT}/ossim/stable/include
OSSIM_LIBRARY:FILEPATH=${INSTALLROOT}/ossim/stable/lib64/libossim.so

PYTHON_EXECUTABLE:FILEPATH=/usr/bin/python
OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_QT:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON

OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_EXTERNAL_MUPARSER:BOOL=ON
OTB_USE_EXTERNAL_TINYXML:BOOL=ON
OTB_USE_EXTERNAL_EXPAT:BOOL=ON
OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_OPENCV:BOOL=ON

##external LibKML
OTB_USE_EXTERNAL_LIBKML:BOOL=ON

 ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
