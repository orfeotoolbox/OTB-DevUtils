# Client maintainer: manuel.grizonnet@cnes.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/OTB")
SET (CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Fedora20-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k install" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)
set(CTEST_HG_COMMAND "/usr/bin/hg")

set(dashboard_root_name "tests")
set(dashboard_source_name "trunk/OTB")
set(dashboard_binary_name "bin/OTB-Nightly")

#set(dashboard_fresh_source_checkout TRUE)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-Nightly")
set(dashboard_hg_branch "default")

#set(ENV{DISPLAY} ":0.0")
set(OTB_INSTALL_PREFIX "/home/otbtesting/install/OTB-Release")
set(INSTALLROOT "/home/otbtesting/install/")

macro(dashboard_hook_init)
set(dashboard_cache "${dashboard_cache}
OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/ssh/pc-inglada/media/TeraDisk2/LargeInput

OTB_DATA_ROOT:STRING=/home/otbtesting/OTB/trunk/OTB-Data

CMAKE_C_FLAGS:STRING=-Wall -Wno-uninitialized
CMAKE_CXX_FLAGS:STRING=-Wno-cpp
CMAKE_INSTALL_PREFIX:PATH=${OTB_INSTALL_PREFIX}
OTB_COMPILE_WITH_FULL_WARNING=ON
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON


##external ITK
OTB_USE_EXTERNAL_ITK:BOOL=ON
#install location of ITK trunk build
ITK_DIR:PATH=${INSTALLROOT}/ITK_trunk-Release/lib/cmake/ITK-4.6

##external OSSIM
OTB_USE_EXTERNAL_OSSIM:BOOL=ON
OSSIM_INCLUDE_DIR:PATH=${INSTALLROOT}/include
OSSIM_LIBRARY:FILEPATH=${INSTALLROOT}/lib64/libossim.so

##ITK_USE_OPTIMIZED_REGISTRATION_METHODS:BOOL=ON

BUILD_APPLICATIONS:BOOL=ON
OTB_WRAP_PYTHON:BOOL=ON
PYTHON_EXECUTABLE:FILEPATH=/usr/bin/python
OTB_WRAP_QT:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON

OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_EXTERNAL_MUPARSER:BOOL=ON
OTB_USE_EXTERNAL_LIBKML:BOOL=ON
##external LibKML
LIBKML_INCLUDE_DIR:PATH=${INSTALLROOT}/include 
LIBKML_BASE_LIBRARY:FILEPATH=${INSTALLROOT}/lib/libkmlbase.so 
LIBKML_CONVENIENCE_LIBRARY:FILEPATH=${INSTALLROOT}/lib/libkmlconvenience.so 
LIBKML_DOM_LIBRARY:FILEPATH=${INSTALLROOT}/lib/libkmldom.so 
LIBKML_ENGINE_LIBRARY:FILEPATH=${INSTALLROOT}/lib/libkmlengine.so 
LIBKML_MINIZIP_LIBRARY:FILEPATH=${INSTALLROOT}/lib/libminizip.so 
LIBKML_REGIONATOR_LIBRARY:FILEPATH=${INSTALLROOT}/lib/libkmlregionator.so 
LIBKML_XSD_LIBRARY:FILEPATH=${INSTALLROOT}/lib/libkmlxsd.so

OTB_USE_EXTERNAL_TINYXML:BOOL=ON
OTB_USE_EXTERNAL_EXPAT:BOOL=ON

OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_OPENCV:BOOL=ON

    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
