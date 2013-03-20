# Client maintainer: julien.malik@c-s.fr
set(dashboard_model Experimental)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/OTB")
SET (CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "ITKv4-nopatch-Fedora17-64bits-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_COMMAND "/usr/bin/make -j4 -i -k" )
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 1500)

set(CTEST_HG_COMMAND "/usr/bin/hg")
#set(CTEST_HG_UPDATE_OPTIONS "-r otb-itkv4")

set(dashboard_root_name "tests")
set(dashboard_source_name "trunk/OTB-ITKv4")
set(dashboard_binary_name "bin/OTB-ITKv4-nopatch-${CTEST_BUILD_CONFIGURATION}")

set(dashboard_fresh_source_checkout ON)
set(dashboard_hg_url "https://bitbucket.org/julienmalik/otb-itkv4")
set(dashboard_hg_branch "default")

macro(dashboard_hook_init)
  set(dashboard_cache "${dashboard_cache}

CMAKE_C_FLAGS:STRING=-fPIC -Wall -Wshadow -Wno-uninitialized -Wno-unused-variable
CMAKE_CXX_FLAGS:STRING=-fPIC -Wall -Wno-deprecated -Wno-uninitialized -Wno-unused-variable

BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
BUILD_APPLICATIONS:BOOL=ON

OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON
OTB_WRAP_QT:BOOL=ON

OTB_DATA_USE_LARGEINPUT:BOOL=OFF
OTB_DATA_LARGEINPUT_ROOT:STRING=/media/ssh/pc-inglada/media/TeraDisk2/LargeInput
OTB_DATA_ROOT:STRING=/home/otbtesting/OTB/trunk/OTB-Data

OTB_USE_EXTERNAL_ITK:BOOL=ON
ITK_DIR:PATH=$ENV{HOME}/OTB/bin/ITKv4-upstream-Release

OTB_USE_CURL:BOOL=ON
OTB_USE_PQXX:BOOL=OFF
OTB_USE_PATENTED:BOOL=OFF
OTB_USE_EXTERNAL_BOOST:BOOL=ON
OTB_USE_EXTERNAL_EXPAT:BOOL=ON
OTB_USE_EXTERNAL_FLTK:BOOL=ON
OTB_USE_MAPNIK:BOOL=OFF

    ")
endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
