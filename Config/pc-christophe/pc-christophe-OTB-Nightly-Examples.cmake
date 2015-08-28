# Client maintainer: manuel.grizonnet@cnes.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/")
set(CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Fedora20-64bits-clang-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j2 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_DASHBOARD_TRACK Examples)

set(CTEST_GIT_COMMAND "/usr/bin/git")

set(CTEST_NIGHTLY_START_TIME "20:00:00 CEST")
set(CTEST_DROP_METHOD "http")
set(CTEST_DROP_SITE "dash.orfeo-toolbox.org")
set(CTEST_DROP_LOCATION "/submit.php?project=OTB")
set(CTEST_DROP_SITE_CDASH TRUE)

string(TOLOWER ${dashboard_model} lcdashboard_model)

set(dashboard_root_name "tests")
set(dashboard_source_name "sources/orfeo/trunk/OTB-Nightly")
set(dashboard_binary_name "build/orfeo/trunk/build-examples")

#set(dashboard_fresh_source_checkout OFF)
set(dashboard_git_url "https://git@git.orfeo-toolbox.org/git/otb.git")

#set(ENV{DISPLAY} ":0.0")

macro(dashboard_hook_init)
set(dashboard_cache "

CMAKE_C_COMPILER=/usr/bin/clang
CMAKE_CXX_COMPILER=/usr/bin/clang++
CMAKE_C_FLAGS:STRING=-Wall -Wno-uninitialized  -Wno-unused-variable -Wno-gnu
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-deprecated -Wno-uninitialized -Wno-gnu -Wno-overloaded-virtual -Wno-\\#warnings

BUILD_TESTING:BOOL=ON
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/TeraDisk2/LargeInput
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}sources/orfeo/OTB-Data
OTB_DIR:PATH=${CTEST_DASHBOARD_ROOT}build/orfeo/trunk/OTB-clang-ThridPartyTrunk/${CTEST_BUILD_CONFIGURATION}

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

##external muparserx
MUPARSERX_LIBRARY:PATH=${INSTALLROOT}/muparserx/lib/libmuparserx.so
MUPARSERX_INCLUDE_DIR:PATH=${INSTALLROOT}/muparserx/include

#external openjpeg
OpenJPEG_DIR:PATH=${INSTALLROOT}/openjpeg/trunk/lib/openjpeg-2.1

")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
