# Client maintainer: manuel.grizonnet@cnes.fr
#SET(ENV{DISPLAY} ":0")

set(dashboard_model Experimental)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/Dashboards")
set(CTEST_SITE "pc-grizonnetm.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Debug)
set(CTEST_BUILD_NAME "ITKv4-Ubuntu10.04-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Eclipse CDT4 - Unix Makefiles")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 500)
set(CTEST_BUILD_COMMAND "/usr/bin/make -j6 -i -k" )

set(CTEST_HG_COMMAND "/usr/bin/hg")
#set(CTEST_HG_UPDATE_OPTIONS "-r otb-itkv4") 

set(dashboard_root_name "My_Tests")
set(dashboard_source_name "My_Tests/OTB-ITKv4")
set(dashboard_binary_name "My_Tests/bin/OTB-ITKv4-${CTEST_BUILD_CONFIGURATION}")

set(dashboard_fresh_source_checkout TRUE)
set(dashboard_hg_url "https://bitbucket.org/julienmalik/otb-itkv4")
set(dashboard_hg_branch "default")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

OTB_DATA_USE_LARGEINPUT:BOOL=OFF
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/TeraDisk2/LargeInput
OTB_DATA_ROOT:STRING=/mnt/dd-2/OTB/trunk/OTB-ITKv4-Data

CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wshadow -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON

OTB_USE_EXTERNAL_ITK:BOOL=ON
ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/${dashboard_root_name}/bin/ITKv4-Debug

GDAL_CONFIG:STRING=/home/otbtesting/local/bin/gdal_trunk/bin/gdal-config
GDALCONFIG_EXECUTABLE:STRING=/home/otbtesting/local/bin/gdal_trunk/bin/gdal-config
GDAL_INCLUDE_DIR:STRING=/home/otbtesting/local/bin/gdal_trunk/include
GDAL_LIBRARY:STRING=/home/otbtesting/local/bin/gdal_trunk/lib/libgdal.so
OGR_INCLUDE_DIRS:STRING=/home/otbtesting/local/bin/gdal_trunk/include

OTB_USE_CURL:BOOL=ON
OTB_USE_PQXX:BOOL=OFF
OTB_USE_PATENTED:BOOL=OFF
OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_EXTERNAL_EXPAT:BOOL=ON
OTB_USE_EXTERNAL_FLTK:BOOL=ON
USE_FFTWD:BOOL=OFF
USE_FFTWF:BOOL=OFF
OTB_GL_USE_ACCEL:BOOL=OFF
OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_VISU_GUI:BOOL=ON 
BUILD_APPLICATIONS:BOOL=ON
OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_QT:BOOL=ON
#OTB_WRAP_PYQT:BOOL=ON
    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/otb_common.cmake)
