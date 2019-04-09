# Run nightly test on each remote module
set(dashboard_model Nightly)
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "MacOSX10.10-${CTEST_BUILD_CONFIGURATION}")
include(${CTEST_SCRIPT_DIRECTORY}/leod_common.cmake)

string(TOLOWER ${dashboard_model} lcdashboard_model)
set(dashboard_source_name "${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/src")
set(dashboard_binary_name "${lcdashboard_model}/OTB-${CTEST_BUILD_CONFIGURATION}/build-remotes")
set(dashboard_remote_modules 1)
set(dashboard_no_install 1)

# filter the list
# set(dashboard_remote_blacklist OTBBioVars OTBPhenology OTBTemporalGapFilling)

set(dashboard_cache "
BUILD_EXAMPLES:BOOL=OFF
CMAKE_PREFIX_PATH:PATH=/Users/otbval/Dashboard/xdk-6.6
CMAKE_C_FLAGS:STRING= -fPIC -Wall
CMAKE_CXX_FLAGS:STRING= -fPIC -Wall -Wno-gnu -Wno-gnu-static-float-init -Wno-\\\\#warnings
OTB_DATA_USE_LARGEINPUT:BOOL=OFF
OTB_DATA_ROOT:STRING=$ENV{HOME}/Data/OTB-Data
BUILD_SHARED_LIBS:BOOL=ON
BUILD_TESTING:BOOL=ON
OTB_BUILD_DEFAULT_MODULES:BOOL=OFF
OTB_USE_CURL:BOOL=ON
OTB_USE_LIBKML:BOOL=ON
OTB_USE_LIBSVM:BOOL=ON
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_QT:BOOL=ON
OTB_USE_QWT:BOOL=ON
OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON
OTB_USE_GLFW:BOOL=ON
OTB_USE_GLUT:BOOL=ON
OTB_USE_MPI:BOOL=OFF
OTB_USE_SPTW:BOOL=ON
OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_SHARK:BOOL=ON
OTB_USE_OPENMP:BOOL=ON

GLUT_glut_LIBRARY=/usr/X11R6/lib/libglut.3.dylib
GLUT_INCLUDE_DIR=/usr/X11R6/include

")

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
