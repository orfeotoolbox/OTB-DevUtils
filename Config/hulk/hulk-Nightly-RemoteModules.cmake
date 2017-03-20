# Run nightly test on each remote module
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Ubuntu14.04-64bits-${CTEST_BUILD_CONFIGURATION}")
include(${CTEST_SCRIPT_DIRECTORY}/hulk_common.cmake)
set(dashboard_remote_modules 1)
set(dashboard_no_install 1)

set(dashboard_model "Nightly")
set(dashboard_source_name "src/OTB")
set(dashboard_binary_name "build/build-remotes")

# filter the list
set(dashboard_remote_blacklist OTBBioVars OTBPhenology OTBTemporalGapFilling)

set(dashboard_cache "
BUILD_EXAMPLES:BOOL=OFF
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/src/OTB-Data
BUILD_SHARED_LIBS:BOOL=ON
BUILD_TESTING:BOOL=ON
OTB_BUILD_DEFAULT_MODULES:BOOL=OFF
OTB_USE_CURL:BOOL=ON
OTB_USE_LIBKML:BOOL=ON
OTB_USE_LIBSVM:BOOL=ON
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_QT4:BOOL=ON
OTB_USE_QWT:BOOL=ON
OTB_USE_OPENGL:BOOL=ON
OTB_USE_GLEW:BOOL=ON
OTB_USE_GLFW:BOOL=ON
OTB_USE_GLUT:BOOL=ON
OTB_USE_MPI:BOOL=ON
OTB_USE_SPTW:BOOL=ON
OTB_USE_MAPNIK:BOOL=ON
OTB_USE_SHARK:BOOL=ON
ITK_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/ITK-4.10.0/lib/cmake/ITK-4.10
OSSIM_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/ossim-1.8.20-3/include
OSSIM_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/install/ossim-1.8.20-3/lib/libossim.so
OpenCV_DIR:PATH=/usr/share/OpenCV
MUPARSERX_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/install/muparserx/lib/libmuparserx.so
MUPARSERX_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/muparserx/include
SHARK_LIBRARY:FILEPATH=${CTEST_DASHBOARD_ROOT}/install/shark/lib/libshark_debug.so
SHARK_INCLUDE_DIR:PATH=${CTEST_DASHBOARD_ROOT}/install/shark/include
")

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
