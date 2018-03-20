# Client maintainer: manuel.grizonnet@cnes.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/")
set(CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Fedora22-64bits-${CTEST_BUILD_CONFIGURATION}-SHOW_ALL_WARNINGS")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_FLAGS "-j4 -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)
set(CTEST_HG_COMMAND "/usr/bin/hg")
set(CTEST_HG_UPDATE_OPTIONS "-C")

set(dashboard_root_name "tests")
set(dashboard_source_name "sources/orfeo/trunk/OTB-Nightly")
set(dashboard_binary_name "build/orfeo/trunk/OTB-Nightly-SHOW_ALL_WARNINGS/${CTEST_BUILD_CONFIGURATION}")

#set(dashboard_fresh_source_checkout TRUE)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-Nightly")
set(dashboard_hg_branch "default")

#set(ENV{DISPLAY} ":0.0")
set(INSTALLROOT "${CTEST_DASHBOARD_ROOT}install")

macro(dashboard_hook_init)
ctest_read_custom_files(${dashboard_binary_name})
set(dashboard_cache "${dashboard_cache}
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
BUILD_APPLICATIONS:BOOL=ON

##CMAKE_C_COMPILER=/usr/bin/clang
##CMAKE_CXX_COMPILER=/usr/bin/clang++
##CMAKE_C_FLAGS:STRING=-Wall -Wno-uninitialized  -Wno-unused-variable -Wno-gnu
##CMAKE_CXX_FLAGS:STRING=-Wall -Wno-deprecated -Wno-uninitialized -Wno-gnu -Wno-overloaded-virtual -Wno-\\\\#warnings

CMAKE_C_FLAGS:STRING= -Wall
CMAKE_CXX_FLAGS:STRING= -Wall -Wextra

##external ITK
ITK_DIR:PATH=${INSTALLROOT}/itk/trunk/Release/lib/cmake/ITK-4.13

##external OSSIM
OSSIM_INCLUDE_DIR:PATH=${INSTALLROOT}/ossim/release/include
OSSIM_LIBRARY:FILEPATH=${INSTALLROOT}/ossim/release/lib64/libossim.so


OTB_COMPILE_WITH_FULL_WARNING:BOOL=ON

##OTB_FULL_WARNING_LIST_PARAMETERS:STRING=-Weverything -Wall

OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}sources/orfeo/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=OFF
OTB_USE_PATENTED:BOOL=ON
OTB_USE_CURL:BOOL=ON
OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_EXTERNAL_EXPAT:BOOL=ON
OTB_USE_EXTERNAL_ITK:BOOL=ON
OTB_USE_EXTERNAL_OSSIM:BOOL=ON
OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_OPENCV:BOOL=ON
OTB_WRAP_JAVA:BOOL=OFF
OTB_WRAP_PYTHON:BOOL=OFF
OTB_WRAP_QT:BOOL=ON


")
endmacro()

set(dashboard_no_test true) #no ctest just squeeze out warnings. Verify this with Manuel.

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
