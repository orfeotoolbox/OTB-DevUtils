# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Experimental)
set(CTEST_DASHBOARD_ROOT "$ENV{HOME}/OTB-NIGHTLY-VALIDATION")
set(CTEST_SITE "dora.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "ITKv4-Ubuntu10.04-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_COMMAND "/ORFEO/otbval/OTB-OUTILS/cmake/2.8.2/install/bin/cmake" )
set(CTEST_CMAKE_GENERATOR "Eclipse CDT4 - Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j8 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)

set(CTEST_HG_COMMAND "/usr/bin/hg")
set(CTEST_HG_UPDATE_OPTIONS "-r otb-itkv4") 

set(dashboard_root_name "tests")
set(dashboard_source_name "src/OTB-ITKv4")
set(dashboard_binary_name "build/OTB-ITKv4-${CTEST_BUILD_CONFIGURATION}")

set(dashboard_fresh_source_checkout ON)
set(dashboard_hg_url "https://bitbucket.org/julienmalik/otb-itkv4")
set(dashboard_hg_branch "default")

SET(OTB_GDAL_INSTALL_DIR "$ENV{HOME}/OTB-OUTILS/gdal/install-linux-gdal-1.9.0")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}
BUILDNAME:STRING=${CTEST_BUILD_NAME}
SITE:STRING=${CTEST_SITE}
CTEST_USE_LAUNCHERS:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=$ENV{HOME}/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/WWW.ORFEO-TOOLBOX.ORG-CS-NIGHTLY/OTB-Data

CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

CMAKE_BUILD_TYPE:STRING=Release
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON

OTB_USE_EXTERNAL_ITK:BOOL=ON
ITK_DIR:PATH=/ORFEO/otbval/OTB-NIGHTLY-VALIDATION/build/ITKv4-${CTEST_BUILD_CONFIGURATION}

OTB_USE_CURL:BOOL=ON
OTB_USE_PQXX:BOOL=OFF
ITK_USE_PATENTED:BOOL=OFF
OTB_USE_PATENTED:BOOL=OFF
OTB_USE_EXTERNAL_BOOST:BOOL=ON
BOOST_INCLUDEDIR:STRING=/ORFEO/otbval/OTB-OUTILS/boost/install/include
BOOST_LIBRARYDIR:STRING=/ORFEO/otbval/OTB-OUTILS/boost/install/lib
OTB_USE_EXTERNAL_EXPAT:BOOL=ON
OTB_USE_EXTERNAL_FLTK:BOOL=ON
FLTK_DIR:PATH=$ENV{HOME}/OTB-OUTILS/fltk/binaries-linux-shared-release-fltk-1.1.9
USE_FFTWD:BOOL=OFF
USE_FFTWF:BOOL=OFF
OTB_GL_USE_ACCEL:BOOL=OFF
OTB_USE_MAPNIK:BOOL=ON
MAPNIK_INCLUDE_DIR:PATH=/ORFEO/otbval/OTB-OUTILS/mapnik/install/include
MAPNIK_LIBRARY:FILEPATH=/ORFEO/otbval/OTB-OUTILS/mapnik/install/lib/libmapnik.so

GDALCONFIG_EXECUTABLE:FILEPATH=${OTB_GDAL_INSTALL_DIR}/bin/gdal-config
GDAL_CONFIG:FILEPATH=${OTB_GDAL_INSTALL_DIR}/bin/gdal-config
GDAL_INCLUDE_DIR:STRING=${OTB_GDAL_INSTALL_DIR}/include
GDAL_LIBRARY:FILEPATH=${OTB_GDAL_INSTALL_DIR}/lib/libgdal.so

    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/otb_common.cmake)

