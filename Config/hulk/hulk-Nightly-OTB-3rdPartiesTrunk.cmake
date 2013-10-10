# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbval/Dashboard")
set(CTEST_SITE "hulk.c-s.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Ubuntu10.04-64bits-${CTEST_BUILD_CONFIGURATION}-3rdPartiesTrunk")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j9 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)
set(CTEST_HG_COMMAND "/usr/bin/hg")

set(dashboard_root_name "tests")
set(dashboard_source_name "src/OTB")
set(dashboard_binary_name "build/OTB-3rdPartiesTrunk")

#set(dashboard_fresh_source_checkout TRUE)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-Nightly")
set(dashboard_hg_branch "default")

set(ENV{DISPLAY} ":0.0")
set(ENV{LD_LIBRARY_PATH} "/home/otbval/Dashboard/install/openjpeg-r2249/lib:$ENV{LD_LIBRARY_PATH}")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
BUILD_APPLICATIONS:BOOL=ON
OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_QT:BOOL=ON
#OTB_WRAP_PYQT:BOOL=ON


CMAKE_C_FLAGS:STRING= -Wall -Wno-uninitialized -Wno-unused-variable -fPIC
CMAKE_CXX_FLAGS:STRING= -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable -fPIC

OTB_DATA_USE_LARGEINPUT:BOOL=ON
OTB_DATA_LARGEINPUT_ROOT:STRING=/home/otbval/Data/OTB-LargeInput
OTB_DATA_ROOT:STRING=$ENV{HOME}/Dashboard/src/OTB-Data

ITK_USE_PATENTED:BOOL=ON
ITK_USE_REVIEW:BOOL=ON
ITK_USE_OPTIMIZED_REGISTRATION_METHODS:BOOL=ON
OTB_USE_PATENTED:BOOL=ON
OTB_USE_PQXX:BOOL=OFF
OTB_USE_CURL:BOOL=ON
OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_EXTERNAL_EXPAT:BOOL=ON
OTB_USE_EXTERNAL_FLTK:BOOL=ON
USE_FFTWD:BOOL=ON
USE_FFTWF:BOOL=ON
OTB_GL_USE_ACCEL:BOOL=OFF
OTB_USE_MAPNIK:BOOL=ON
OTB_USE_JPEG2000:BOOL=OFF

OTB_USE_EXTERNAL_OSSIM:BOOL=ON
OSSIM_INCLUDE_DIR:PATH=$ENV{HOME}/Dashboard/install/ossim-trunk/include
OSSIM_LIBRARY:FILEPATH=$ENV{HOME}/Dashboard/install/ossim-trunk/lib/libossim.so

GDAL_INCLUDE_DIR:STRING=$ENV{HOME}/Dashboard/install/gdal-trunk/include
GDAL_LIBRARY:FILEPATH=$ENV{HOME}/Dashboard/install/gdal-trunk/lib/libgdal.so
    ")
endmacro()


SET(CTEST_NOTES_FILES
    "$ENV{HOME}/Dashboard/nightly/logs/build_gdal_trunk.log"
    "$ENV{HOME}/Dashboard/nightly/logs/build_ossim_trunk.log")

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
