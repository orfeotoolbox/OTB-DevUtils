# Run nightly test on each remote module
set(CTEST_BUILD_CONFIGURATION Release)
set(CTEST_BUILD_NAME "Fedora22-64bits-${CTEST_BUILD_CONFIGURATION}")
include(${CTEST_SCRIPT_DIRECTORY}/pc-christophe_common.cmake)
set(dashboard_remote_modules 1)
set(dashboard_no_install 1)

set(dashboard_root_name "tests")
set(dashboard_source_name "sources/orfeo/trunk/OTB-Nightly")
set(dashboard_binary_name "build/orfeo/trunk/OTB-Nightly-RemotesModules/${CTEST_BUILD_CONFIGURATION}")

# filter the list
#set(dashboard_remote_blacklist OTBBioVars OTBPhenology OTBTemporalGapFilling)

set(dashboard_cache "
BUILD_EXAMPLES:BOOL=OFF
CMAKE_C_FLAGS:STRING=-Wall
CMAKE_CXX_FLAGS:STRING=-Wall -Wno-cpp --std=c++11 -Wno-unknown-pragmas
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}/sources/orfeo/OTB-Data
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
OTB_USE_SHARK:BOOL=OFF
## ITK
ITK_DIR:PATH=${INSTALLROOT}/itk/stable/Release/lib/cmake/ITK-4.10

## OSSIM
OSSIM_INCLUDE_DIR:PATH=${INSTALLROOT}/ossim/release/include
OSSIM_LIBRARY:FILEPATH=${INSTALLROOT}/ossim/release/lib64/libossim.so

##external muparserx
MUPARSERX_LIBRARY:PATH=${INSTALLROOT}/muparserx/stable/lib/libmuparserx.so
MUPARSERX_INCLUDE_DIR:PATH=${INSTALLROOT}/muparserx/stable/include/muparserx
# shark
#Shark_DIR=${INSTALLROOT}/shark/stable/lib/cmake/Shark
")

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
