# Client maintainer: manuel.grizonnet@cnes.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/")
SET (CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Fedora20-64bits-clang-ThirdPartyTrunk-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j2 -i -k install" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)
set(CTEST_HG_COMMAND "/usr/bin/hg")

set(dashboard_root_name "tests")
set(dashboard_source_name "sources/orfeo/trunk/OTB-Nightly")
set(dashboard_binary_name "build/orfeo/trunk/OTB-clang-ThridPartyTrunk/${CTEST_BUILD_CONFIGURATION}")

#set(dashboard_fresh_source_checkout TRUE)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-Nightly")
set(dashboard_hg_branch "default")
set(CTEST_USE_LAUNCHERS 1)

set(INSTALLROOT "${CTEST_DASHBOARD_ROOT}install")
set (OTB_INSTALL_PREFIX "${INSTALLROOT}/orfeo/trunk/OTB-clang-ThirdPartyTrunk/${CTEST_BUILD_CONFIGURATION}")

#set(ENV{DISPLAY} ":0.0")

macro(dashboard_hook_init)
set(dashboard_cache "${dashboard_cache}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
BUILD_APPLICATIONS:BOOL=ON

CMAKE_C_COMPILER=/usr/bin/clang
CMAKE_CXX_COMPILER=/usr/bin/clang++
CMAKE_C_FLAGS:STRING=-Wall -Wno-uninitialized  -Wno-unused-variable -Wno-gnu
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-deprecated -Wno-uninitialized -Wno-gnu -Wno-overloaded-virtual -Wno-\\#warnings
CMAKE_INSTALL_PREFIX=${OTB_INSTALL_PREFIX}

##external GDAL
GDAL_CONFIG:FILEPATH=${INSTALLROOT}/gdal/trunk/bin/gdal-config
GDAL_INCLUDE_DIR:PATH=${INSTALLROOT}/gdal/trunk/include/
GDAL_LIBRARY:FILEPATH=${INSTALLROOT}/gdal/trunk/lib/libgdal.so

##external ITK
ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}build/itk/trunk/Release

##external OpenCV
OpenCV_DIR=${INSTALLROOT}/opencv/trunk/share/OpenCV/

##external OSSIM
OSSIM_INCLUDE_DIR:PATH=${INSTALLROOT}/ossim/trunk/include
OSSIM_LIBRARY:FILEPATH=${INSTALLROOT}/ossim/trunk/lib64/libossim.so

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/ssh/pc-inglada/media/TeraDisk2/LargeInput
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}sources/orfeo/OTB-Data
OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_EXTERNAL_EXPAT:BOOL=ON
OTB_USE_EXTERNAL_LIBKML:BOOL=ON
OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_OPENCV:BOOL=ON
OTB_USE_EXTERNAL_ITK:BOOL=ON
OTB_USE_EXTERNAL_OSSIM:BOOL=ON
OTB_WRAP_QT:BOOL=ON
OTB_WRAP_JAVA:BOOL=OFF
OTB_WRAP_PYTHON:BOOL=OFF
 ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
