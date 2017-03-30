# Client maintainer: manuel.grizonnet@cnes.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/")
SET (CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Fedora22-64bits-clang-ThirdPartyTrunk-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_FLAGS "-j4 -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)
set(CTEST_DASHBOARD_TRACK Experimental)

set(dashboard_root_name "tests")
set(dashboard_source_name "sources/orfeo/trunk/OTB-Nightly")
set(dashboard_binary_name "build/orfeo/trunk/OTB-clang-ThirdPartyTrunk/${CTEST_BUILD_CONFIGURATION}")

#set(dashboard_fresh_source_checkout TRUE)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")
set(CTEST_USE_LAUNCHERS ON)

set(INSTALLROOT "${CTEST_DASHBOARD_ROOT}install")
set (CTEST_INSTALL_DIRECTORY "${INSTALLROOT}/orfeo/trunk/OTB-clang-ThirdPartyTrunk/${CTEST_BUILD_CONFIGURATION}")

set(ENV{GDAL_DATA} "${CTEST_DASHBOARD_ROOT}sources/gdal/trunk/gdal/data")

#execute_process(COMMAND ${CMAKE_COMMAND} -E remove_directory "${CTEST_INSTALL_DIRECTORY}")

macro(dashboard_hook_init)
set(dashboard_cache "${dashboard_cache}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
BUILD_APPLICATIONS:BOOL=ON

CMAKE_C_COMPILER=/usr/bin/clang
CMAKE_CXX_COMPILER=/usr/bin/clang++
CMAKE_C_FLAGS:STRING=-Wall
CMAKE_CXX_FLAGS:STRING=-std=c++11 -Wall -Wno-gnu-static-float-init -Wno-\\\\#warnings  -Wno-unknown-attributes
CMAKE_INSTALL_PREFIX=${CTEST_INSTALL_DIRECTORY}

##external GDAL
GDAL_CONFIG:FILEPATH=${INSTALLROOT}/gdal/trunk/bin/gdal-config
GDAL_INCLUDE_DIR:PATH=${INSTALLROOT}/gdal/trunk/include
GDAL_LIBRARY:FILEPATH=${INSTALLROOT}/gdal/trunk/lib/libgdal.so

##external ITK
ITK_DIR:PATH=${INSTALLROOT}/itk/trunk/Release/lib/cmake/ITK-4.11

##external OpenCV
OpenCV_DIR=${INSTALLROOT}/opencv/trunk

##external OSSIM
OSSIM_INCLUDE_DIR:PATH=${INSTALLROOT}/ossim/dev/include
OSSIM_LIBRARY:FILEPATH=${INSTALLROOT}/ossim/dev/lib64/libossim.so

##external muparserx
MUPARSERX_LIBRARY:PATH=${INSTALLROOT}/muparserx/trunk/lib/libmuparserx.so
MUPARSERX_INCLUDE_DIR:PATH=${INSTALLROOT}/muparserx/trunk/include/muparserx


OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/TeraDisk2/LargeInput
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}sources/orfeo/OTB-Data

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
# Ice module
OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON
OTB_USE_GLFW:BOOL=ON
OTB_USE_GLUT:BOOL=ON
 ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
