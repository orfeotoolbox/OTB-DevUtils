# Client maintainer: manuel.grizonnet@cnes.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/mnt/dd-2/OTB")
SET (CTEST_SITE "pc-grizonnetm.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Clang-Ubuntu10.04-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j8 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)
set(CTEST_HG_COMMAND "/usr/bin/hg")

set(dashboard_root_name "tests")
set(dashboard_source_name "trunk/OTB-Nightly")
set(dashboard_binary_name "OTB-Binary-Clang-Experimental")

#set(dashboard_fresh_source_checkout TRUE)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-Nightly")
set(dashboard_hg_branch "default")

#set(ENV{DISPLAY} ":0.0")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_CXX_COMPILER:STRING=/usr/local/bin/clang++

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/mnt/dd-2/OTB/trunk/OTB-Data/LargeInput

OTB_DATA_ROOT:STRING=/mnt/dd-2/OTB/trunk/OTB-Data

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
OTB_USE_CURL:BOOL=ON
OTB_USE_PQXX:BOOL=OFF
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

GDAL_CONFIG:STRING=/home/grizonnetm/Local/gdal-1.7.1-build/bin/gdal-config
GDALCONFIG_EXECUTABLE:STRING=/home/grizonnetm/Local/gdal-1.7.1-build/bin/gdal-config
GDAL_INCLUDE_DIR:STRING=/home/grizonnetm/Local/gdal-1.7.1-build/include
GDAL_LIBRARY:STRING=/home/grizonnetm/Local/gdal-1.7.1-build/lib/libgdal.so
OGR_INCLUDE_DIRS:STRING=/home/grizonnetm/Local/gdal-1.7.1-build/include
BUILD_APPLICATIONS:BOOL=ON
WRAP_PYTHON:BOOL=ON
WRAP_QT:BOOL=ON
WRAP_PYQT:BOOL=ON

    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/otb_common.cmake)


