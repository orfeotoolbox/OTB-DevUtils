# Client maintainer: manuel.grizonnet@cnes.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/mnt/dd-2/OTB")
SET (CTEST_SITE "pc-grizonnetm.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Ubuntu10.04-64bits-${CTEST_BUILD_CONFIGURATION}-GDAL_trunk")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j8 -i -k install")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)
set(CTEST_HG_COMMAND "/usr/bin/hg")

set(dashboard_root_name "tests")
set(dashboard_source_name "trunk/OTB-Nightly")
set(dashboard_binary_name "OTB-Binary-Nightly")

#set(dashboard_fresh_source_checkout TRUE)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-Nightly")
set(dashboard_hg_branch "default")

#set(ENV{DISPLAY} ":0.0")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/TeraDisk2/LargeInput

OTB_DATA_ROOT:STRING=/mnt/dd-2/OTB/trunk/OTB-Data

CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable
CMAKE_INSTALL_PREFIX:STRING=/mnt/dd-2/OTB/OTB-Binary-Nightly-Install
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
OTB_USE_CURL:BOOL=ON
OTB_USE_PQXX:BOOL=ON
OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_EXTERNAL_EXPAT:BOOL=ON
OTB_USE_DEPRECATED:BOOL=ON
ITK_USE_PATENTED:BOOL=ON
OTB_USE_PATENTED:BOOL=ON
USE_FFTWD:BOOL=ON
USE_FFTWF:BOOL=ON
OTB_GL_USE_ACCEL:BOOL=ON 
OTB_USE_VISU_GUI:BOOL=OFF
ITK_USE_REVIEW:BOOL=ON 
ITK_USE_OPTIMIZED_REGISTRATION_METHODS:BOOL=ON 
OTB_USE_MAPNIK:BOOL=ON
MAPNIK_INCLUDE_DIR:STRING=/usr/include
MAPNIK_LIBRARY:STRING=/usr/lib/libmapnik.so
GDAL_CONFIG:STRING=/home/otbtesting/local/bin/gdal_trunk/bin/gdal-config
GDALCONFIG_EXECUTABLE:STRING=/home/otbtesting/local/bin/gdal_trunk/bin/gdal-config
GDAL_INCLUDE_DIR:STRING=/home/otbtesting/local/bin/gdal_trunk/include
GDAL_LIBRARY:STRING=/home/otbtesting/local/bin/gdal_trunk/lib/libgdal.so
OGR_INCLUDE_DIRS:STRING=/home/otbtesting/local/bin/gdal_trunk/include
BUILD_APPLICATIONS:BOOL=ON
OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_QT:BOOL=ON
#OTB_WRAP_PYQT:BOOL=ON

    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/otb_common.cmake)
