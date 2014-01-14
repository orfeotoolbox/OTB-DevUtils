# Client maintainer: manuel.grizonnet@cnes.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/OTB")
SET (CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION "External-OSSIM_svn22473-Release")
set(CTEST_BUILD_NAME "Fedora17-64bits-clang-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j2 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)
set(CTEST_HG_COMMAND "/usr/bin/hg")

set(dashboard_root_name "tests")
set(dashboard_source_name "trunk/OTB")
set(dashboard_binary_name "bin/OTB-clang-Nightly")

#set(dashboard_fresh_source_checkout TRUE)
set(dashboard_hg_url "http://hg.orfeo-toolbox.org/OTB-Nightly")
set(dashboard_hg_branch "default")

set(ENV{DISPLAY} ":0.0")

macro(dashboard_hook_init)
set(dashboard_cache "${dashboard_cache}
OTB_DATA_USE_LARGEINPUT:BOOL=OFF
#OTB_DATA_LARGEINPUT_ROOT:STRING=/media/ssh/pc-inglada/media/TeraDisk2/LargeInput

OTB_DATA_ROOT:STRING=/home/otbtesting/OTB/trunk/OTB-Data
#using external clang due to fedora 17
CMAKE_C_COMPILER=/home/otbtesting/local/bin/clang
CMAKE_CXX_COMPILER=/home/otbtesting/local/bin/clang++

CMAKE_C_FLAGS:STRING=-Wall -Wno-uninitialized -Wno-unused-variable -Wno-gnu
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable -Wno-gnu

#external ITK
OTB_USE_EXTERNAL_ITK:BOOL=ON 

##using external ossim due to clang error in nested class
OTB_USE_EXTERNAL_OSSIM:BOOL=ON 
OSSIM_INCLUDE_DIR:STRING=/home/otbtesting/local/include 
OSSIM_LIBRARY:STRING=/home/otbtesting/local/lib/libossim.so 

##clang boost 1.4x bug. using boost 1.54.0
##https://svn.boost.org/trac/boost/ticket/6156
Boost_INCLUDE_DIR:STRING=/home/otbtesting/local/include 
Boost_LIBRARY_DIRS:STRING=/home/otbtesting/local/lib/

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
##ITK_USE_OPTIMIZED_REGISTRATION_METHODS:BOOL=ON
OTB_USE_VISU_GUI:BOOL=ON
BUILD_APPLICATIONS:BOOL=ON
OTB_WRAP_PYTHON:BOOL=ON
PYTHON_EXECUTABLE:FILEPATH=/usr/bin/python
OTB_WRAP_QT:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON

OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_EXTERNAL_FLTK:BOOL=ON
OTB_USE_MAPNIK:BOOL=OFF
#MAPNIK_INCLUDE_DIR:STRING=/usr/include
#MAPNIK_LIBRARY:STRING=/usr/lib/libmapnik.so
    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)

