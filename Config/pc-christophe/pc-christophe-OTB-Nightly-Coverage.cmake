# Client maintainer: manuel.grizonnet@cnes.fr
set(dashboard_model Nightly)
set(CTEST_DASHBOARD_ROOT "/home/otbtesting/")
set(CTEST_SITE "pc-christophe.cst.cnes.fr")
set(CTEST_BUILD_CONFIGURATION Debug)
set(CTEST_BUILD_NAME "Fedora28-64bits-Coverage-${CTEST_BUILD_CONFIGURATION}")
set(CTEST_CMAKE_GENERATOR "Unix Makefiles")
set(CTEST_BUILD_CONFIGURATION Debug)
set(CTEST_BUILD_FLAGS "-j4 -k" )
set(CTEST_COVERAGE_COMMAND "/usr/bin/gcov")
set(CTEST_TEST_ARGS PARALLEL_LEVEL 4)
set(CTEST_TEST_TIMEOUT 2500)
set(dashboard_no_install 1)

set(dashboard_root_name "tests")
set(dashboard_source_name "sources/orfeo/trunk/OTB-Nightly")
set(dashboard_binary_name "build/orfeo/trunk/OTB-Nightly-Coverage/${CTEST_BUILD_CONFIGURATION}")

set(dashboard_do_coverage true)
set(INSTALLROOT "${CTEST_DASHBOARD_ROOT}install")

set(ENV{OTB_LOGGER_LEVEL} "DEBUG")

macro(dashboard_hook_init)

# NOTE: -Wno-deprecated-declarations, is in CXX flags to hide 'itkLegacyMacro' related warning
# under gcc 5.1.1, to work around GCC bug 65974.
# It should be removed when gcc is updated on pc-christophe

set(dashboard_cache "${dashboard_cache}
BUILD_TESTING:BOOL=ON
BUILD_EXAMPLES:BOOL=ON
BUILD_APPLICATIONS:BOOL=ON

CMAKE_C_FLAGS:STRING=-g -O0 -fprofile-arcs -ftest-coverage -Wall -Wextra -Wlogical-op -Wshadow
CMAKE_CXX_FLAGS:STRING=-g -O0 -fprofile-arcs -ftest-coverage -Wall -Wextra -Wno-cpp -Wno-deprecated-declarations -Wlogical-op -Wshadow

## ITK
ITK_DIR:PATH=${INSTALLROOT}/itk/stable/Release/lib/cmake/ITK-4.13

## OSSIM
OSSIM_INCLUDE_DIR:PATH=${INSTALLROOT}/ossim/release/include
OSSIM_LIBRARY:FILEPATH=${INSTALLROOT}/ossim/release/lib64/libossim.so

##external muparserx
MUPARSERX_LIBRARY:PATH=${INSTALLROOT}/muparserx/stable/lib/libmuparserx.so
MUPARSERX_INCLUDE_DIR:PATH=${INSTALLROOT}/muparserx/stable/include/muparserx

#external glfw
GLFW_INCLUDE_DIR:PATH=/usr/include/GLFW
GLFW_LIBRARY:PATH=/usr/lib64/libglfw.so

OTB_DATA_LARGEINPUT_ROOT:STRING=/media/TeraDisk2/LargeInput
OTB_DATA_ROOT:STRING=${CTEST_DASHBOARD_ROOT}sources/orfeo/OTB-Data
OTB_DATA_USE_LARGEINPUT:BOOL=ON

# These options are not available anymore
OTB_USE_PATENTED:BOOL=ON
OTB_USE_CURL:BOOL=ON

PYTHON_EXECUTABLE:FILEPATH=/usr/bin/python
OTB_WRAP_PYTHON:BOOL=ON
OTB_WRAP_JAVA:BOOL=ON

#QWT include (not found automatically)
QWT_INCLUDE_DIR::PATH=/usr/include/qt5/qwt

#OTB_USE_XXX
OTB_USE_6S=ON
OTB_USE_CURL=ON
OTB_USE_LIBKML=OFF
OTB_USE_LIBSVM=ON
OTB_USE_MAPNIK:BOOL=OFF
OTB_USE_MUPARSER:BOOL=ON
OTB_USE_MUPARSERX:BOOL=ON
OTB_USE_OPENCV:BOOL=ON
OTB_USE_QT=ON
OTB_USE_QWT:BOOL=ON
OTB_USE_SIFTFAST=ON
OTB_USE_OPENGL=ON
OTB_USE_GLUT=ON
OTB_USE_GLEW=ON
OTB_USE_GLFW=ON
OTB_USE_MPI=ON
OTB_USE_SPTW=ON

OTB_USE_OPENMP:BOOL=ON
")

endmacro()

include(${CTEST_SCRIPT_DIRECTORY}/../otb_common.cmake)
